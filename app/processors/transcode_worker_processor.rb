require "transcoder/transcoder"
require "transcoder/tools/ffmpeg"

class TranscodeWorkerProcessor < ApplicationProcessor

  publishes_to :uploader_worker
  subscribes_to :transcode_worker

  include Transcoder::InstanceMethods
  include ActiveMessaging::MessageSender
  include PostbackHelper
  
  def on_message(message) 
    begin
      logger.debug "TranscodeWorkerProcessor received: " + message
      puts "TranscodeWorkerProcessor received: " + message

      job = Job.find(get_job_id(message))
      transcode(job)
      logger.debug "job.save = #{job.save}"

      # postback? - job complete
      if(job.status == 'completed')
        convert_post_back job, 'success'
        # also upload completed video if upload_url is not null.
        if job.user.upload_url
          publish(
            :uploader_worker,
            {'video_id'=> job.convert_file_id,
              'job_id'  => job.id 
          }.to_json
          )
        end
      else
        convert_post_back job, 'fail'
      end
    ensure
      # tell scaler of my own death.
      me=WorkerProcess.find(JSON.parse(message)["worker_process_id"])
      me.state = WorkerProcess::DEAD
      me.save
    end
  end
   
  #  {"type": "ASSIGN", "content": {"config": {"OriginalFile": "1", "ConvertJob": "1"}, "node_name": "Converter"}}
  def get_job_id message
    msg = JSON.parse message

    # the former is proposed scaler message.
    # the latter is legacy API message.
    msg["job_id"] || msg["content"]["config"]["ConvertJob"]
  end
  
  
end                          
