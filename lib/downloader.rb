# Axel - http://alioth.debian.org/projects/axel/
# Usage: axel [options] url1 [url2] [url...]
# 
# -s x    Specify maximum speed (bytes per second)
# -n x    Specify maximum number of connections
# -o f    Specify local output file
# -S [x]  Search for mirrors and download from x servers
# -H x    Add header string
# -U x    Set user agent
# -N      Just don't use any proxy server
# -q      Leave stdout alone
# -v      More status information
# -a      Alternate progress indicator
# -h      This information
# -V      Version information

# TODO: more test with redirects... 
class Downloader
  
    TEMP_FOLDER = "/tmp" unless defined? TEMP_FOLDER
    USER_AGENT  = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11) Gecko/20071231 Firefox/2.0.0.11 Flock/1.0.5" unless defined? USER_AGENT
    
    class << self 
      include Transcoder::Helper
    end

    def self.command(url, local_filename )
      url = "http://" + url if (url =~ /^(http|ftp):\/\//).nil?
      url.gsub!(/ /,'')
      # "curl -o \"#{hashed_name}\" -L -A \"#{USER_AGENT}\" \"#{URI.parse(url)}\"  2>&1"
      "axel -o \"#{local_filename}\" -U \"#{USER_AGENT}\" \"#{URI.parse(url)}\"  2>&1"
    end
    
    def self.download(url)
      progress = nil

      raise DownloadError if url.blank?

      hashed_name = Digest::SHA1.hexdigest("--#{Time.now.to_i.to_s}--#{url}--")
      
      _command = "cd #{TEMP_FOLDER} &&  #{command(url,hashed_name)}"
      logger.debug _command
      IO.popen(_command) do |pipe|
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
      return File.join(TEMP_FOLDER,hashed_name)

    end
    
    def self.logger
      @@logger = RAILS_DEFAULT_LOGGER if !defined?(@@logger) && (defined?(RAILS_DEFAULT_LOGGER) && !RAILS_DEFAULT_LOGGER.nil?)
      @@logger = ActiveRecord::Base.logger unless defined?(@@logger)
      @@logger = Logger.new(STDOUT) unless defined?(@@logger)
      @@logger
    end
    
    class DownloadError < RuntimeError ; end
    
end