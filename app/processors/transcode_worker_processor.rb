require "transcoder/transcoder"
require "transcoder/tools/ffmpeg"

class TranscodeWorkerProcessor < ApplicationProcessor

  subscribes_to :transcode_worker

  include Transcoder::InstanceMethods
  
  def on_message(message) 
    logger.debug "TranscodeWorkerProcessor received: " + message
    puts "TranscodeWorkerProcessor received: " + message
    
    job = Job.find(get_job_id(message))
    transcode(job)
        
  end
   
  #  {"type": "ASSIGN", "content": {"config": {"OriginalFile": "1", "ConvertJob": "1"}, "node_name": "Converter"}}
  def get_job_id message
    msg = JSON.parse message
    msg["content"]["config"]["ConvertJob"]
  end
  
  
end                          