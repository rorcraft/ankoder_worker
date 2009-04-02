module Transcoder
  module Tools
    class Http
      require 'hmac'
      require 'hmac-sha1'

      def self.post_back(job,result,error="")

        if job.postback_url.blank?
          Transcoder.logger.debug "Postback URL is blank"
          return ""
        end

        message = {"result" => "#{result}", "error" => error , "type" => "Convert" , "Job"=> job.id  }

        if result == "success"
          message = message.merge({ "convert_video_id" => job.convert_file_id, "s3_name" => job.convert_file_s3_name })
        end 
        message = message.to_json
        encoded_message = Base64.encode64(HMAC::SHA1::digest(job.user.private_key, message)).strip
        curl_cmd = "curl -H \"Content-type: application/x-www-form-urlencoded\" #{job.postback_url} -d \"message=#{CGI.escape(message)}&signature=#{CGI.escape(encoded_message)}\""
        f = IO.popen(curl_cmd +" 2>&1")
        result = f.read
        f.close

        result
      end

    end
  end
end

