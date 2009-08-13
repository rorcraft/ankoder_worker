class UploaderProcessor < ApplicationProcessor
  subscribes_to :uploader_worker

  #  include PostbackHelper

  def on_message(message)
    logger.debug "UploaderProcessor received #{message}"
    params = JSON.parse message
    job = Job.find params['job_id']
    video = Video.find job.convert_file.id
    user = video.user
    upload_url = job.get_upload_url
    username = user.upload_username
    password = user.upload_password
    uploader_temp_file = nil
    thumbnail_destination = job.get_thumbnail_upload_url
    destination_s3_public = job.profile.destination_s3_public || job.user.destination_s3_public

    begin

      video.set_status ConvertFile::UPLOADING

      if S3_ON
        #local_file_path = Uploader.download s3_url, Uploader.make_temp_filename
        local_file_path = uploader_temp_file = Downloader.download(
          :url => video.s3_url,
          :local_filename => Uploader.make_temp_filename 
        )
      else
        local_file_path = video.file_path
      end

      # upload the video
      upload_options = {
        :video_id              => video.id,
        :upload_url            => upload_url,
        :local_file_path       => local_file_path,
        :remote_filename       => "#{video.id}_#{video.filename}",
        :username              => username,
        :password              => password,
        :destination_s3_public => destination_s3_public
      }
      upload_options.merge!({:content_type => video.content_type}) unless video.content_type.blank?
      Uploader.upload(upload_options)
      video.set_status ConvertFile::UPLOADED
      # postback
      Postback.post_back('upload', job, 'success')
    rescue Exception => e
      video.set_status ConvertFile::FAILED
      error_message = case e
                      when HttpError
                        "HTTP status #{e.message}"
                      when HostNotFoundError
                        'Upload URL unreachable'
                      when AccessDeniedError
                        'Authentication failed'
                      when Uploader::UploadError
                        e.message
                      when DownloadTimeoutError
                        'Upload connection timed out'
                      else
                        logger.error e.to_yaml
                        logger.error e.backtrace.to_yaml
                        'Ankoder internal error'
                      end
      Postback.post_back('upload', job, 'fail', error_message)
    ensure
      if S3_ON && uploader_temp_file && File.exist?(uploader_temp_file)
        File.delete(uploader_temp_file)
        # tell scaler of my own death.
      end
      if (JSON.parse(message)["worker_process_id"] rescue false)
        me=WorkerProcess.find(JSON.parse(message)["worker_process_id"])
        me.destroy
      else
        logger.fatal "\n\n\n\nCan't parse JSON\n\n\n\n"
      end
    end
  end
end
