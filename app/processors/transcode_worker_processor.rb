class TranscodeWorkerProcessor < ApplicationProcessor

  subscribes_to :transcode_worker

  def on_message(message)
    logger.debug "TranscodeWorkerProcessor received: " + message
    
    
  end
  
end                          