class WorkerController < ApplicationController
  ACTION_TO_PROCESSOR = {
    "transcode" => TranscodeWorkerProcessor,
    "download"  => DownloaderProcessor,
    "upload"    => UploaderProcessor
  }

  def transcode
    send_to("transcode", params["message"])
  end

  def kill
    `kill -9 #{params["pid"]}`
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
