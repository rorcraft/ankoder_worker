module Transcoder
  module Tools
    # moved to s3curl plugin since it is shared with both worker and api controller
    # 
    # class S3
    #     class S3DownloadError < StandardError ;      end
    #     class S3UploadError < StandardError ;        end
    #     class S3AccessDenied < StandardError ;       end
    #     class S3NoSuchBucket < StandardError ;       end
    #   
    #     class << self 
    #       include Transcoder::Helper
    #     end
    #     
    #     
    #     # we wrap curl with ruby for more stability        
    #     S3CURL = "#{RAILS_ROOT}/lib/transcoder/bin/s3curl.pl" unless defined? S3CURL
    # 
    #     # def self.create_bucket(bucket)
    #     #   f = IO.popen("#{S3CURL} --id=personal -- http://s3.amazonaws.com/bucket/")
    #     #   f.close
    #     # end
    # 
    #     # s3curl.pl --id AWSAccessKeyId (or friendly name) [--key SecretAccessKey (unsafe)] [--contentType text/plain] [--original_name Original Filename (for put)] [--acl public-read] [--put index.html | --createBucket [Location constraint e.g. "EU"]| --head] -- [curl-options]
    #     def self.get_curl_command(command)
    #       f = IO.popen(command +" 2>&1")
    #       command = f.read
    #       command = command.split("\n").last
    #       f.close
    # 
    #       command
    #     end
    # 
    #     # upload to S3
    #     # option is a hash
    #     # * <tt>"public"</tt>: true or false
    #     # * <tt>"original_filename"</tt>: filename
    #     def self.upload(s3_filename , local_filename , option = {})
    #        progress = nil
    #     
    #        addition_option = ""
    #        addition_option += " --acl public-read " if option["public"]
    #        addition_option += " --original_name=\"#{CGI.escape(option["original_filename"])}\" " unless option["original_filename"].blank?
    #        
    #        bucket = option["bucket"] || S3BUCKET
    # 
    #        curl_command  = get_curl_command("#{S3CURL} #{access_param} #{addition_option} --put=#{local_filename} -- http://s3.amazonaws.com/#{bucket}/#{s3_filename}")
    #        
    #        Transcoder.logger.debug curl_command 
    #     
    #        IO.popen("#{curl_command}  2>&1") do |pipe|
    #          pipe.each("\r") do |line|
    #            case line
    #            when /NoSuchBucket/
    #              raise S3NoSuchBucket
    #            when /AccessDenied/ 
    #              raise S3AccessDenied      
    #            when /(\d+)/                 
    #              p = $1.to_i
    #              p = 100 if p > 100
    #              if progress != p
    #                progress = p
    #                block_given? ? yield(progress) : stdout_progress(progress)
    #                $defout.flush
    #              end
    #            end
    #          end
    #        end
    #        block_given? ? yield(100) : stdout_progress(100)
    #        raise S3UploadError if $?.exitstatus != 0
    #      end
    # 
    #      def self.download(filename , local_file, options = {} )
    #        #./lib/transcoder/bin/s3curl.pl --id=ankoder --debug -- http://s3.amazonaws.com/moming2k/test.txt -o ~/test.txt  2>&1
    #        progress = nil        
    #        bucket = S3BUCKET || options.delete(:bucket)   
    #        command = get_curl_command("#{S3CURL} #{access_param} -- http://s3.amazonaws.com/#{bucket}/#{filename}")
    #        command += " -o #{local_file}  2>&1"
    #        
    #        Transcoder.logger.debug command
    #        
    #        IO.popen("#{command}") do |pipe|
    #          pipe.each("\r") do |line|
    #            if line =~ /(\d+)/
    #              p = $1.to_i
    #              p = 100 if p > 100
    #              if progress != p
    #                progress = p
    #                block_given? ? yield(progress) : stdout_progress(progress)
    #                $defout.flush
    #              end
    #            end
    #          end
    #        end
    #        block_given? ? yield(100) : stdout_progress(100)
    #        raise S3DownloadError if $?.exitstatus != 0
    #        return local_file
    #      end
    #     
    #     def self.head(filename, options  = {} )
    #       bucket = S3BUCKET || options.delete(:bucket)
    #       cmd = get_curl_command("#{S3CURL} #{access_param} --head http://s3.amazonaws.com/#{bucket}/#{filename}")
    #       output = IO.popen("#{cmd}  2>&1") 
    #       output.read
    #     end
    #     
    #     def self.delete(filename, options = {})
    #       bucket = S3BUCKET || options.delete(:bucket)
    #       cmd = get_curl_command("#{S3CURL} #{access_param} --delete http://s3.amazonaws.com/#{bucket}/#{filename}")
    #       output = IO.popen("#{cmd}  2>&1") 
    #       output.read          
    #     end
    #       
    #       
    #     def self.access_param
    #       " --id=ankoder "
    #     end
    # 
    #     private
    #     
    # 
    #     
    # end
  end
end