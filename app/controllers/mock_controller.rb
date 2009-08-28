require "json"

class MockController < ApplicationController
  ACTION_TO_PROCESSOR = {
    "transcode" => TranscodeWorkerProcessor,
    "download"  => DownloaderProcessor,
    "upload"    => UploaderProcessor
  }

  include Spawn
  before_filter :parse_params

  def art_thou_there
    pids = params["pids"] || [0]
    render :text => CGI.escape({"private_dns_name" => `hostname`.strip, "pids" => %x[ps #{pids.join(" ")}].split($/).map{|i|i.scan(/^\s*\d+/).first.to_i}.select{|i|i>0}}.to_json)
  end

  def parse_params
    @msg = (JSON.parse(params["message"]) rescue "gotcha")
  end

  def index
    render :text => @msg.inspect
  end

  def kill
    render :text => "OK"
  end

  def self_defense
    head :"404"
  end

  def download
    send_to("download", params["message"])
  end

  def upload
    send_to("upload", params["message"])
  end

  def transcode
    send_to("transcode", params["message"])
  end

  def delay
    spawn do sleep 10 end
    render :text => proc{|r,o|o.write "super\n"; o.flush}
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
