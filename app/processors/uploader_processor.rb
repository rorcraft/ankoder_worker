class UploaderProcessor < ApplicationProcessor
  subscribes_to :uploader_worker

  include PostbackHelper

  def on_message(message)
    logger.debug "UploaderProcessor received #{message}"
    params = JSON.parse message
    video = Video.find params['video_id']
    s3_url = S3_ON ? video.s3_url : ''
    local_file_path = S3_ON ? nil : video.file_path
    user = video.user
    upload_url = user.upload_url
    username = user.upload_username
    password = user.upload_password

    #handles s3 as a special case
    if upload_url =~ %r[http://s3\.amazonaws\.com/([^/]+)(/(.+))?]
      S3Curl.upload(\
                    $3 ? $3 : video.s3_name,
                    local_file_path, {:bucket => $1})
      upload_post_back(video,'success')
      return
    end

    Uploader.upload \
      :upload_url      => upload_url,
      :s3_url          => s3_url,
      :local_file_path => local_file_path,
      :username        => username,
      :password        => password
    # postback
    upload_post_back(video,'success')
  rescue Exception => e
    upload_post_back(video,'fail')
    raise e
  end
end
