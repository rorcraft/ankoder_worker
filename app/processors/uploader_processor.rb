class UploaderProcessor < ApplicationProcessor
  subscribes_to :uploader_worker

  include PostbackHelper

  def on_message(message)
    logger.debug "UploaderProcessor received #{message}"
    params = JSON.parse message
    video = Video.find params['video_id']
    s3_name = video.s3_name
    user = video.user
    upload_url = user.upload_url
    username = user.upload_username
    password = user.upload_password
    uploader_temp_file = nil

    begin

      if S3_ON
        #local_file_path = Uploader.download s3_url, Uploader.make_temp_filename
        local_file_path = uploader_temp_file = Downloader.download(
          :url => video.s3_url,
          :local_filename => Uploader.make_temp_filename 
        )
      else
        local_file_path = video.file_path
      end

      Uploader.upload(
        :video_id        => video.id,
        :thumbnail_url   => video.thumbnail_url,
        :upload_url      => upload_url,
        :s3_name         => s3_name,
        :local_file_path => local_file_path,
        :remote_filename => video.filename,
        :username        => username,
        :password        => password
      )
      # postback
      upload_post_back(video,'success')
    rescue Exception => e
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
      upload_post_back(video,'fail', error_message)
    ensure
       if S3_ON && File.exist?(uploader_temp_file)
         File.delete(uploader_temp_file)
       end
    end
  end
end
