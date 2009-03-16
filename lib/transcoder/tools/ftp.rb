module Transcoder
  module Tools
    
    class Ftp
      CURL = "curl" unless defined? "CURL"
      class << self 
        include Transcoder::Helper
      end
      
      def self.upload(options = {})
        return if options.empty?
        progress = nil
        path      = options.delete(:path)
        filename  = options.delete(:filename)
        username  = options.delete(:username)
        password  = options.delete(:password)
        host      = options.delete(:host)
        
        path = "/#{path}" unless path[0,1] == "/" 
        path = "#{path}/" unless path[-1,1] == "/" 
        
        target = File.basename(filename) if target.blank?
        upload_url = "ftp://#{username}:#{password}@#{host}#{path}#{target}"
        
        IO.popen("#{CURL} -T #{filename} #{upload_url} 2>&1") do |pipe|
          pipe.each("\r") do |line|
            if line =~ /(\d+)/
              p = $1.to_i
              p = 100 if p > 100
              if progress != p
                progress = p
                # @logger.debug "progress = #{progress}, duration = #{duration}"
                block_given? ? yield(progress) : stdout_progress(progress)
                $defout.flush
              end
            end
          end
        end
        block_given? ? yield(100) : stdout_progress(100)
        raise FtpUploadError if $?.exitstatus != 0
      end
    
    
      class FtpUploadError < StandardError ; end 
      
      
      
    end  
  end
end