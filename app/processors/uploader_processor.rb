class UploaderProcessor < ApplicationProcessor

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
    file_map = {}

    begin

      video.set_status ConvertFile::UPLOADING

      if S3_ON
        video.s3_names.each do |name|
          file_map[name] = Downloader.download(
            :url => video.s3_url_from_name(name),
            :local_filename => Uploader.make_temp_filename)
        end
      else
        video.local_names.each do |name|
          file_map[video.segment_s3_name(name)] = video.segment_path(name)
        end
      end

      # upload the video
      file_map.each do |s3_name, local_file_path|
        upload_options = {
          :video_id              => video.id,
          :upload_url            => upload_url,
          :local_file_path       => local_file_path,
          :remote_filename       => s3_name,
          :original_name         => s3_name,
          :username              => username,
          :password              => password,
          :destination_s3_public => destination_s3_public
        }
        upload_options.merge!({:content_type => video.content_type}) if !video.content_type.blank?
        Uploader.upload(upload_options)
      end
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
                        'Ankoder internal error'
                      end
      logger.error e.to_yaml
      logger.error e.backtrace[0,20].to_yaml
      Postback.post_back('upload', job, 'fail', error_message)
    ensure
      if S3_ON
        file_map.each do |s3_name, local_file_path|
          File.delete(local_file_path) if File.exist?(local_file_path)
        end
      end
      # tell scaler of my own death.
      if (JSON.parse(message)["worker_process_id"] rescue false)
        me=WorkerProcess.find(JSON.parse(message)["worker_process_id"])
        me.destroy
      end
    end
  end
end
