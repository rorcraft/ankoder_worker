class UploaderProcessor < ApplicationProcessor
  subscribes_to :uploader_worker

  include PostbackHelper

  def on_message(message)
    logger.debug "UploaderProcessor received #{message}"
    params = JSON.parse message
    video = Video.find params['video_id']
    job = Job.find params['job_id']
    user = video.user
    upload_url = job.get_upload_url
    username = user.upload_username
    password = user.upload_password
    uploader_temp_file = nil
    thumbnail_destination = job.thumbnail_destination
    thumbnail_sizes = job.get_thumbnail_sizes

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

      # upload thumbnails
      if thumbnail_destination && thumbnail_sizes.length > 0
        thumbnail_sizes.each do |size|
          size = size.to_sym
          Uploader.upload(
            :upload_url      => thumbnail_destination,
            :local_file_path => video.thumbnail_full_path(nil,size),
            :remote_filename => video.thumbnail_name(nil,size)
          )
        end
      end

      # upload the video
      Uploader.upload(
        :video_id        => video.id,
        :thumbnail_url   => video.thumbnail_url,
        :upload_url      => upload_url,
        :local_file_path => local_file_path,
        :remote_filename => video.filename,
        :username        => username,
        :password        => password
      )
      # postback
      upload_post_back(video,job,'success')
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
      upload_post_back(video,job,'fail', error_message)
    ensure
      if S3_ON && File.exist?(uploader_temp_file)
        File.delete(uploader_temp_file)
      end
    end
  end
end
