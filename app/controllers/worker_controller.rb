class WorkerController < ApplicationController
  ACTION_TO_PROCESSOR = {
    :transcode => TranscodeWorkerProcessor,
    :download  => DownloaderProcessor,
    :upload    => UploaderProcessor
  }

  def_each :transcode, :download, :upload do |action|
    send_to(action, params["message"])
  end

  private
  def send_to(processor_action, message)
    spawn do
      ACTION_TO_PROCESSOR[processor_action].new.on_message(message)
    end
    render :text => "OK"
  end
end
