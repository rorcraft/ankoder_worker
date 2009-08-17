require "transcoder/transcoder"
require "transcoder/tools/ffmpeg"
require "transcoder/tools/ffmpeg2theora"

class TranscodeWorkerProcessor < ApplicationProcessor

  include Transcoder
  include Transcoder::InstanceMethods
  include ActiveMessaging::MessageSender

  def on_message(message) 
      logger.debug "TranscodeWorkerProcessor received: " + message
      job = Job.find(get_job_id(message))
      destination_s3_public = job.profile.destination_s3_public || job.user.destination_s3_public
    begin
      transcode(job)

      # upload thumbnails to external storage
      job.thumbnails.each do |thumbnail|
        next unless File.exist?(thumbnail.file_path)
        begin
          Uploader.upload(
            :upload_url            => job.get_thumbnail_upload_url,
            :local_file_path       => thumbnail.file_path,
            :remote_filename       => thumbnail.filename,
            :destination_s3_public => destination_s3_public
          )
          thumbnail.uploaded = true
        rescue
          thumbnail.uploaded = false
        end
      end if job.get_thumbnail_upload_url && job.thumbnails

      # postback? - job complete
      Postback.post_back 'convert', job, 'success'
      # also upload completed video if upload_url is not null.
      if job.get_upload_url
        job.convert_file.set_status ConvertFile::QUEUEING
      end
    rescue
      error = case $!
              when TranscoderError::MediaFormatException then "conversion failure"
              when TranscoderError::MPrBoxHintingException then "hinting failure"
              else "ankoder internal error"
              end
      Postback.post_back 'convert', job, 'fail', error
      logger.error " ------------- !!!!!!!!!!!!!! -------------"
      error_msg = $!.class.to_s
      error_msg += $!.message
      error_msg += $!.backtrace[0,20].to_yaml
      job.set_error(error_msg)
      job.set_status Job::FAILED
      logger.error error_msg
    ensure
      # tell scaler of my own death.
      if (JSON.parse(message)["worker_process_id"] rescue false)
        me=WorkerProcess.find(JSON.parse(message)["worker_process_id"])
        me.destroy
      else
        logger.fatal "\n\n\n\nCan't parse JSON\n\n\n\n"
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
