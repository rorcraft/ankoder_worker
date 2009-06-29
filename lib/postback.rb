class Postback

  CURL_FLAGS =
    %Q[ \\
      -v -L -Y 100 \\
      --connect-timeout #{TimeoutDetector::DETECTOR_TIMEOUT_SEC} \\
      -y #{TimeoutDetector::DETECTOR_TIMEOUT_SEC} \\
    ]

  def self.logger
    Transcoder.logger 
  end
 
  def self.post_back(type, model, result, error='')
    return if (!model.respond_to?('profile') || model.profile.postback_url.blank?) && model.user.postback_url.blank?
    case type
    when 'download'
      message = {
        "result" => result, 
        "error" => error, 
        "type" => "Download", 
        "video_id"=> model.id, 
        "video_name" => model.name 
      }

    when 'convert'
      message = {
        'result'  =>  result,
        'error'   =>  error,
        'type'    => 'Convert',
        'Job'     =>  model.id
      }
      if result   == 'success'
        message['convert_video_id'] = model.convert_file.id
        message['s3_name'] = model.convert_file.s3_name
        message['name'] = "#{model.convert_file.id}_#{model.convert_file.filename}" 
      end

    when 'upload'
      message = {
        'Job'     => model.id,
        'result'  => result,
        'error'   => error,
        'type'    => 'Upload',
        'Video'   => model.convert_file.id,
        'url'     => model.get_upload_url,
        'filename'=> model.convert_file.filename,
        'thumbnail_name'=> model.convert_file.thumbnail_name  
      }
    end

    message = message.to_json
    private_key = model.user.private_key
    
    encoded_message = Base64.encode64(HMAC::SHA1::digest(private_key, message)).strip

    postback_url = (model.respond_to?('profile') && model.profile.postback_url) ? model.profile.postback_url : model.user.postback_url

    curl_cmd = "curl #{CURL_FLAGS} -H \"Content-type: application/x-www-form-urlencoded\" #{postback_url} -d \"message=#{CGI.escape(message)}&signature=#{CGI.escape(encoded_message)}\""
    logger.info curl_cmd
    f = IO.popen(curl_cmd +" 2>&1")
    result = f.read
    f.close
  rescue Exception => e
    logger.debug result
    logger.error e.to_yaml
    logger.error e.backtrace.to_yaml
  end

=begin
  def self.download_post_back(video , result, error="")
    return if video.profile.postback_url.blank? && video.user.postback_url.blank?
    message = {\
      "result" => result, 
      "error" => error, 
      "type" => "Download", 
      "video_id"=> video.id, 
      "video_name" => video.name 
    }

    message = message.to_json
    private_key = video.user.private_key
    
    encoded_message = Base64.encode64(HMAC::SHA1::digest(private_key, message)).strip

    postback_url = video.profile.postback_url ? video.profile.postback_url : video.user.postback_url

    curl_cmd = "curl #{CURL_FLAGS} -H \"Content-type: application/x-www-form-urlencoded\" #{postback_url} -d \"message=#{CGI.escape(message)}&signature=#{CGI.escape(encoded_message)}\""
    logger.info curl_cmd
    f = IO.popen(curl_cmd +" 2>&1")
    result = f.read
    f.close
  rescue Exception => e
    logger.debug result
    logger.error e.to_yaml
    logger.error e.backtrace.to_yaml
  end
  
  def convert_post_back(job, result, error='')
    return if job.profile.postback_url.blank? && job.user.postback_url.blank?
    message = {\
      'result'  =>  result,
      'error'   =>  error,
      'type'    => 'Convert',
      'Job'     =>  job.id
    }
    if result   == 'success'
      convert_file = job.convert_file
      message['convert_video_id'] = convert_file.id
      message['s3_name'] = convert_file.s3_name
      message['name'] = "#{convert_file.id}_#{convert_file.filename}" 
    end

    message = message.to_json
    private_key = job.user.private_key

    encoded_message = Base64.encode64(HMAC::SHA1::digest(private_key,message)).strip
    postback_url = job.profile.postback_url ? job.profile.postback_url : job.user.postback_url
    curl_cmd = "curl #{CURL_FLAGS} -H \"Content-type: application/x-www-form-urlencoded\" #{postback_url} -d \"message=#{CGI.escape(message)}&signature=#{CGI.escape(encoded_message)}\""
    
    logger.info curl_cmd
    f = IO.popen(curl_cmd + " 2>&1")
    result = f.read
    f.close
  rescue Exception => e
    logger.debug result
    logger.error e.to_yaml
    logger.error e.backtrace.to_yaml
  end

  def upload_post_back(job, result, error='')
    return if job.profile.postback_url.blank? && job.user.postback_url.blank?
    message = {
      'result'  => result,
      'error'   => error,
      'type'    => 'Upload',
      'Video'   => video.id,
      'url'     => job.get_upload_url,
      'filename'=> job.convert_video.filename
    }

    message = message.to_json
    private_key = video.user.private_key

    encoded_message = Base64.encode64(HMAC::SHA1::digest(private_key,message)).strip
    postback_url = job.profile.postback_url ? job.profile.postback_url : job.user.postback_url
    curl_cmd = "curl #{CURL_FLAGS} -H \"Content-type: application/x-www-form-urlencoded\" #{postback_url} -d \"message=#{CGI.escape(message)}&signature=#{CGI.escape(encoded_message)}\""

    logger.info curl_cmd
    f = IO.popen(curl_cmd + " 2>&1")
    result = f.read
    f.close
  rescue Exception => e
    logger.debug result
    logger.error e.to_yaml
    logger.error e.backtrace.to_yaml
  end
=end

end
