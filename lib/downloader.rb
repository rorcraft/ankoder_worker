
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
    include VideoSiteUrlParse
  end

  class DownloadError < RuntimeError; end

  def self.logger
    @@logger = RAILS_DEFAULT_LOGGER if !defined?(@@logger) &&
      (defined?(RAILS_DEFAULT_LOGGER) && !RAILS_DEFAULT_LOGGER.nil?)
    @@logger = ActiveRecord::Base.logger unless defined?(@@logger)
    @@logger = Logger.new(STDOUT) unless defined?(@@logger)
    @@logger
  end

  def self.escape_quote url
    url.to_s.sub(/"/,'\"')
  end

  def self.url_protocol url
    if url =~ /^http:\/\/s3\.amazonaws\.com\// ||  url =~ /s3\.amazonaws\.com/
      return 's3'
    end
    match=/^(\w+):\/\//.match(url)
    match ? match[1] : nil
  end

  def self.temp_path local_filename
    File.join(TEMP_FOLDER,local_filename)
  end

  def self.command(url, local_filename, options={})
    url = "http://" + url unless (url_protocol url)

    # handles s3 as a special case
    if url =~ /^http:\/\/s3\.amazonaws\.com\//
      url.sub!(/^http:\/\/s3\.amazonaws\.com\//,'s3://')
    elsif url =~ /s3\.amazonaws\.com/
      array = url.split /\.s3\.amazonaws\.com\/?/
      bucket = %r[^http://(.+)].match(array[0])[1]
      file = array[1]
      url = "s3://#{bucket}/#{file}"
    end

    url = parse_video_url url if url_protocol(url)=='http'
    case (protocol = url_protocol url)
    when 'http','ftp'
      if (options[:username] && options[:password] || \
          url =~ /^http:\/\/(www\.)?youtube\.com/
         )
        if !(options[:username] && options[:password])
          options[:username] = 'user'
          options[:password] = 'password'
        end
        %Q(curl -v -L -# -u "#{escape_quote options[:username]}:)+
        %Q(#{escape_quote options[:password]}" )+
          %Q(-A "#{USER_AGENT}" "#{escape_quote URI.parse(url)}")+
          %Q( -o "#{escape_quote File.join(TEMP_FOLDER,local_filename)}" 2>&1)
      else
        %Q(axel -o "#{escape_quote File.join(TEMP_FOLDER,local_filename)}" )+
          %Q(-U "#{USER_AGENT}" "#{escape_quote URI.parse(url)}"  2>&1)
      end
    when 'sftp'
      match = /sftp:\/\/(\w+@)?([^\/]+)(\/.*)/.match url
      raise DownloadError.new('invalid sftp url') unless \
        match && match.length == 4
      userAt = match[1]
      host = match[2]
      path = match[3]
      %Q(scp -B -o PreferredAuthentications=publickey ) +
        %Q("#{userAt ? escape_quote(userAt) : ''}#{escape_quote host}:)+
        %Q(#{escape_quote path}") +
        %Q( "#{escape_quote File.join(TEMP_FOLDER,local_filename)}" 2>&1)
    when 's3'
      match = /s3:\/\/([^\/]+)\/(.+)/.match url
      raise DownloadError.new('invalid s3 url') unless\
        match && match.length == 3
      bucket = match[1]
      file = match[2]
      S3Curl.get_curl_command(%Q(#{S3Curl::S3CURL} #{S3Curl.access_param} -- \\
            "http://s3.amazonaws.com/#{bucket}/#{file}" )\
                             ) + \
                               %Q( -v -o "#{escape_quote File.join(TEMP_FOLDER,local_filename)}" \\
             -# 2>&1)

    else
      raise DownloadError.new('protocol not supported')
    end
  end

  def self.download(*args, &block)
    default_options = {:url => '', :local_filename => 'downloader_test_file'}
    options = default_options.merge(args.extract_options!)
    url = options[:url]
    local_filename = options[:local_filename]
    _command = command(url, local_filename, options)
    application = _command.slice /\S+/
      logger.info _command
    p = progress = nil; # to force 0% update
    IO.popen(_command) do |pipe|
      error_detector = timeout_detector = nil
      begin
        error_detector = ErrorDetector.new(
          application, url_protocol(url),File.join(TEMP_FOLDER,local_filename)
        )
        timeout_detector = TimeoutDetector.new(
          File.join(TEMP_FOLDER,local_filename)
        )
        separator = case application
                    when 'axel' then "\n"
                    when 'curl' then "\r"
                    else "\n"
                    end
        pipe.each(separator) do |line|
          logger.debug line
          error_detector.check_for_error line

          p = case application
              when 'axel'
                line =~ /^\[ *(\d+)%\]/ ? $1.to_i : p
              when 'curl'
                line =~ /(\d+\.\d+)%/ ? $1.to_f.round : p
              else
                p
              end
          if progress != p && progress_need_refresh?(progress, p)
            p = 0 if p < 0
            p = 100 if p > 100
            progress = p
            block_given? ? yield(progress) : stdout_progress(progress)
            $defout.flush
          end
        end
      rescue Exception => e # else a miserable non-standard error
                            # raised herein will bypass it here.
                            # It would even bypass the ensure block.
        # kill the downloader process
        `kill -9 #{pipe.pid}`
        # rethrow exception
        raise e
      ensure
        timeout_detector.exit
      end
    end
    raise DownloadError.new('unknown error') if $?.exitstatus != 0
    file_path = File.join(TEMP_FOLDER,local_filename)
    return File.exists?(file_path) ? file_path : false
  end

end
