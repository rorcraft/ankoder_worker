module PostbackHelper

  CURL_FLAGS =
    %Q[ \\
      -v -L -Y 100 \\
      --connect-timeout #{TimeoutDetector::DETECTOR_TIMEOUT_SEC} \\
      -y #{TimeoutDetector::DETECTOR_TIMEOUT_SEC} \\
    ]

  def download_post_back( video , result, error="")
    return if video.postback_url.blank?
    message = {"result" => result, "error" => error, "type" => "Download" , 
      "video_id"=> video.id, "video_name" => video.name }.to_json
    private_key = video.user.private_key
    
    encoded_message = Base64.encode64(HMAC::SHA1::digest(private_key, message)).strip

    curl_cmd = "curl #{CURL_FLAGS} -H \"Content-type: application/x-www-form-urlencoded\" #{video.postback_url} -d \"message=#{CGI.escape(message)}&signature=#{CGI.escape(encoded_message)}\""
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
    return if job.postback_url.blank?
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
    end

    message = message.to_json
    private_key = job.user.private_key

    encoded_message = Base64.\
      encode64(HMAC::SHA1::digest(private_key,message)).strip
    curl_cmd = %Q{ \\
      curl #{CURL_FLAGS} -H "Content-type: application/x-www-form-urlencoded" \\
      #{job.postback_url} -d \\
      "message=#{CGI.escape(message)}&signature=#{CGI.escape(encoded_message)}"
    }
    logger.info curl_cmd
    f = IO.popen(curl_cmd + " 2>&1")
    result = f.read
    f.close
  rescue Exception => e
    logger.debug result
    logger.error e.to_yaml
    logger.error e.backtrace.to_yaml
  end

  def upload_post_back(video, job, result, error='')
    postback_url = video.user.postback_upload
    return if postback_url.blank?
    message = {
      'result'  => result,
      'error'   => error,
      'type'    => 'Upload',
      'Video'   => video.id,
      'url'     => job.get_upload_url,
      'filename'=> video.filename
    }.to_json
    private_key = video.user.private_key

    encoded_message = Base64.\
      encode64(HMAC::SHA1::digest(private_key,message)).strip
    curl_cmd = %Q{ \\
      curl #{CURL_FLAGS} -H "Content-type: application/x-www-form-urlencoded" \\
      #{postback_url} -d \\
      "message=#{CGI.escape(message)}&signature=#{CGI.escape(encoded_message)}"
    }
    logger.info curl_cmd
    f = IO.popen(curl_cmd + " 2>&1")
    result = f.read
    f.close
  rescue Exception => e
    logger.debug result
    logger.error e.to_yaml
    logger.error e.backtrace.to_yaml
  end

end
