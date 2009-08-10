class WorkerController < ApplicationController
  ACTION_TO_PROCESSOR = {
    "transcode" => TranscodeWorkerProcessor,
    "download"  => DownloaderProcessor,
    "upload"    => UploaderProcessor
  }

  def art_thou_there
    pids = params["pids"] || [0]
    render :text => CGI.escape({"private_dns_name" => `hostname`.strip, "pids" => %x[ps #{pids.join(" ")}].split($/).map{|i|i.scan(/^\s*\d+/).first.to_i}.select{|i|i>0}}.to_json)
  end

  def upload
    send_to("upload", params["message"])
  end

  def download
    send_to("download", params["message"])
  end

  def transcode
    send_to("transcode", params["message"])
  end

  def kill
    me = (WorkerProcess.find params["worker_process_id"] rescue nil)
    if me && me.pid.to_s == params["pid"].to_s
      Process.kill(9, params["pid"].to_i)
    end
    render :text => "OK"
  end

  def sleep_forever
    spawn_id = spawn do
      loop do; sleep 999999; end
    end
    render :text => spawn_id.handle
  end

  private
  def send_to(processor_action, message)
    spawn_id = spawn do
      begin
        ACTION_TO_PROCESSOR[processor_action].new.on_message(message)
      rescue
        Transcoder.logger.error $!
        Transcoder.logger.error $!.backtrace.to_yaml
      end
    end
    render :text => spawn_id.handle
  end
end
