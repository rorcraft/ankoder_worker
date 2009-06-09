module PostbackHelper

  def upload_post_back( video , result, error="")
    return if video.postback_url.blank?
    message = {"result" => result, "error" => error , "custom_fields"=> video.custom_fields , "type" => "Upload" , 
      "video_id"=> video.id, "video_name" => video.name }.to_json
    private_key = video.user.private_key
    
    encoded_message = Base64.encode64(HMAC::SHA1::digest(private_key, message)).strip

    curl_cmd = "curl -H \"Content-type: application/x-www-form-urlencoded\" #{video.postback_url} -d \"message=#{CGI.escape(message)}&signature=#{CGI.escape(encoded_message)}\""
    logger.info curl_cmd
    f = IO.popen(curl_cmd +" 2>&1")
    result = f.read
    f.close
  rescue Exception => e
    logger.debug e
  end
  

end