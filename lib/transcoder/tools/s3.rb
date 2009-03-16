module Transcoder
  module Tools
    class S3
      
        class << self 
          include Transcoder::Helper
        end
        
        # we wrap curl with ruby for more stability        
        S3CURL = "#{RAILS_ROOT}/lib/transcoder/bin/s3curl.pl" unless defined? "S3CURL"
        CURL = "/usr/bin/curl"

        def self.export_to_customer_s3(file) # converted_file
          Transcoder.logger.debug "*** S3 Exporting *** #{Time.now}"    
          Transcoder.logger.debug "user: #{file.user.login}"    
  
          upload(file.s3_name, file.file_path, {"original_filename" => file.original_filename, 
            "AWSAccessKeyId" => convert_file.user.s3_access_key, "SecretAccessKey" => file.user.s3_private_key,
            "Bucket" => "#{file.user.s3_bucket}"  ) do |progress|
              Transcoder.logger.debug "Export progress: #{progress}"                  
            end
          end
    
        end

        def self.create_bucket(bucket)
          f = IO.popen("#{S3CURL} --id=personal -- http://s3.amazonaws.com/bucket/")
          f.close
        end
    
        def self.get_curl_command(command)
          f = IO.popen(command +" 2>&1")
          curl_command = f.read
          f.close
          command = curl_command.split("\n").last
          command
        end
    
        def self.upload(filename , local_file , option = {})
          progress = nil

          addition_option = ""
          addition_option += " --acl public-read " if option["public"]
          addition_option += " --original_name=\"#{CGI.escape(option["original_filename"])}\" " unless option["original_filename"].blank?
          Transcoder.logger.debug "option = #{option.inspect}" 
          unless option["AWSAccessKeyId"].blank?
            access_param = " --id=#{option["AWSAccessKeyId"]} --key #{option["SecretAccessKey"]} "
            bucket = "#{option["Bucket"]}"
          else
            access_param = " --id=personal "
            bucket = "#{S3_BUCKET}"
          end
          
          curl_command  = get_curl_command("#{S3CURL} #{access_param} #{addition_option} --put=#{local_file} -- http://s3.amazonaws.com/#{bucket}/#{filename}")
          Transcoder.logger.debug curl_command 

          IO.popen("#{curl_command}  2>&1") do |pipe|
            pipe.each("\r") do |line|
              if line =~ /(\d+)/
                p = $1.to_i
                p = 100 if p > 100
                if progress != p
                  progress = p
                  block_given? ? yield(progress) : print_progress(progress)
                  $defout.flush
                end
              end
            end
          end
          block_given? ? yield(100) : print_progress(100)
          raise S3UploadError if $?.exitstatus != 0
        end

        def self.download(filename , local_file )
          #./lib/transcoder/bin/s3curl.pl --id=personal --put=test.txt --debug -- http://s3.amazonaws.com/moming2k/test.txt 2>&1
          #./lib/transcoder/bin/s3curl.pl --id=personal --debug -- http://s3.amazonaws.com/moming2k/test.txt -o ~/test.txt  2>&1
          progress = nil
          # "-o #{local_file}"      
          command = get_curl_command("#{S3CURL} --id=personal --  http://s3.amazonaws.com/#{S3_BUCKET}/#{filename}")
          command = command + " -o #{local_file}  2>&1"
          Transcoder.logger.debug command
          IO.popen("#{command}") do |pipe|
            pipe.each("\r") do |line|
              if line =~ /(\d+)/
                p = $1.to_i
                p = 100 if p > 100
                if progress != p
                  progress = p
                  block_given? ? yield(progress) : print_progress(progress)
                  $defout.flush
                end
              end
            end
          end
          block_given? ? yield(100) : print_progress(100)
          raise S3DownloadError if $?.exitstatus != 0
          # return hashed_name
        end

        def print_progress(progress)
          p "#{progress}"
        end

        end
        
        class S3DownloadError < StandardError
        end
    
        class S3UploadError < StandardError
        end
    
    end
  end
end