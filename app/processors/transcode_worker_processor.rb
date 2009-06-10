require "transcoder/transcoder"
require "transcoder/tools/ffmpeg"

class TranscodeWorkerProcessor < ApplicationProcessor

  subscribes_to :transcode_worker

  include Transcoder::InstanceMethods
  include PostbackHelper
  
  def on_message(message) 
    logger.debug "TranscodeWorkerProcessor received: " + message
    puts "TranscodeWorkerProcessor received: " + message
    
    job = Job.find(get_job_id(message))
    transcode(job)
    job.save
    
    # postback? - job complete
    if(job.status == 'complete')
      convert_post_back job, 'success'
    else
      convert_post_back job, 'fail'
    end
        
  end
   
  #  {"type": "ASSIGN", "content": {"config": {"OriginalFile": "1", "ConvertJob": "1"}, "node_name": "Converter"}}
  def get_job_id message
    msg = JSON.parse message
    msg["content"]["config"]["ConvertJob"]
  end
  
  
end                          
