require "transcoder/transcoder"
require "transcoder/tools/ffmpeg"
require "transcoder/tools/ffmpeg2theora"

class TranscodeWorkerProcessor < ApplicationProcessor

  publishes_to :uploader_worker
  subscribes_to :transcode_worker

  include Transcoder::InstanceMethods
  include ActiveMessaging::MessageSender

  def on_message(message) 
      logger.debug "TranscodeWorkerProcessor received: " + message
      job = Job.find(get_job_id(message))

    begin
      transcode(job)

      job = Job.find(get_job_id(message))
      raise "Unfinished job" unless (job.status == 'completed')

      # postback? - job complete
      Postback.post_back 'convert', job, 'success'
      # also upload completed video if upload_url is not null.
      if job.get_upload_url
        publish(
          :uploader_worker, {
          'video_id'=> job.convert_file.id,
          'job_id'  => job.id 
        }.to_json
        )
      end
    rescue
      Postback.post_back 'convert', job, 'fail'
      logger.error " ------------- !!!!!!!!!!!!!! -------------"
      message = $!.class.to_s
      message += $!.message
      message += $!.backtrace[0,20].to_yaml
      job.set_error(message)
      job.set_status Job::FAILED
      logger.error message
    ensure
      # tell scaler of my own death.
      if (JSON.parse(message)["worker_process_id"] rescue false)
        me=WorkerProcess.find(JSON.parse(message)["worker_process_id"])
        me.destroy
      end
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
