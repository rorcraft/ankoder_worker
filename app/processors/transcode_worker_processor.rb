require "transcoder/transcoder"
require "transcoder/tools/ffmpeg"

class TranscodeWorkerProcessor < ApplicationProcessor

  publishes_to :uploader_worker
  subscribes_to :transcode_worker

  include Transcoder::InstanceMethods
  include ActiveMessaging::MessageSender
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
      # also upload completed video
      publish :uploader_worker, {'video_id' => job.convert_file_id}.to_json
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
