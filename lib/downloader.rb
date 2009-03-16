
class Downloader
  
    TEMP_FOLDER = "/tmp" unless defined? "TEMP_FOLDER"
    USER_AGENT  = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071231 Firefox/2.0.0.11 Flock/1.0.5" unless defined? "USER_AGENT"
    
    class << self 
      include Transcoder::Helper
    end

    def self.download(url)
      progress = nil

      raise DownloadError if url.blank?
      url = "http://" + url if (url =~ /^(http|ftp):\/\//).nil?
      url.gsub!(/ /,'')

      hashed_name = Digest::SHA1.hexdigest("--#{Time.now.to_i.to_s}--#{url}--")
      
      command = "cd #{TEMP_FOLDER} &&  curl -o \"#{hashed_name}\" -L -A \"#{USER_AGENT}\" \"#{URI.parse(url)}\"  2>&1" 
      logger.debug command
      IO.popen(command) do |pipe|
        pipe.each("\r") do |line|
          if line =~ /(\d+)/
            p = $1.to_i
            p = 100 if p > 100
            # limit the update rate to prevent too many progress update requests
            # flushing our mongrels
            if progress_need_refresh?(progress, p)
              progress = p
              # @logger.debug "progress = #{progress}, duration = #{duration}"
              block_given? ? yield(progress) : stdout_progress(progress)
              $defout.flush
            end
          end
        end
      end
      raise DownloadError if $?.exitstatus != 0
      return hashed_name

    end
    
    def self.logger
      @@logger = RAILS_DEFAULT_LOGGER if !defined?(@@logger) && (defined?(RAILS_DEFAULT_LOGGER) && !RAILS_DEFAULT_LOGGER.nil?)
      @@logger = ActiveRecord::Base.logger unless defined?(@@logger)
      @@logger = Logger.new(STDOUT) unless defined?(@@logger)
      @@logger
    end
    
    class DownloadError < RuntimeError ; end
    
end