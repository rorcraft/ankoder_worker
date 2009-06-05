
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

  def self.original_download_and_todo_list(url, local_filename)
    progress = nil


    _command = "cd #{TEMP_FOLDER} && #{command(url,local_filename)}"
    logger.debug _command
    IO.popen(_command) do |pipe|
      pipe.each("\n") do |line|

	if line =~ /^\[[\d ]+%\]/ && line =~ /(\d+)/
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
    # TODO: Need to catch different types of errors
    # HTTP/1.1 403 Forbidden
    # 404
    # Timeout (if nothing received in 20mins? check 'axel' interface)
    # failed to login FTP
    raise DownloadError.new('unknown error')if $?.exitstatus != 0
    file_path = File.join(TEMP_FOLDER,local_filename)
    return File.exists?(file_path) ? file_path : false
  end

  def self.logger
    @@logger = RAILS_DEFAULT_LOGGER if !defined?(@@logger) &&
      (defined?(RAILS_DEFAULT_LOGGER) && !RAILS_DEFAULT_LOGGER.nil?)
    @@logger = ActiveRecord::Base.logger unless defined?(@@logger)
    @@logger = Logger.new(STDOUT) unless defined?(@@logger)
    @@logger
  end

  def self.escape_quote url
    raise DownloadError.new('blank url') if url.blank?
    url.sub(/"/,'\"')
  end

  def self.url_protocol url
    match=/^(\w+):\/\//.match(url)
    match ? match[1] : nil
  end

  def self.command(url, local_filename, options={})
    url = escape_quote url
    url = "http://" + url unless (url_protocol url)
    # handles s3 as a special case
    url.sub!(/^http:\/\/s3\.amazonaws\.com\//,'s3://') if \
      url =~ /^http:\/\/s3\.amazonaws\.com\//
    url = parse_video_url url if url_protocol(url)=='http'
    case (protocol = url_protocol url)
    when 'http','ftp'
      if options[:username] && options[:password]
	%Q(curl -L -# -u "#{escape_quote options[:username]}:)+
	%Q(#{escape_quote options[:password]}" )+
	%Q(-A "#{USER_AGENT}" "#{URI.parse(url)}")+
	%Q( -o "#{File.join(TEMP_FOLDER,local_filename)}" 2>&1)
      else
	%Q(axel -o "#{File.join(TEMP_FOLDER,local_filename)}" )+
	  %Q(-U "#{USER_AGENT}" "#{URI.parse(url)}"  2>&1)
      end
    when 'sftp'
      match = /sftp:\/\/(\w+@)?([^\/]+)(\/.*)/.match url
      raise DownloadError.new('invalid sftp url') unless \
	match && match.length == 4
      userAt = match[1]
      host = match[2]
      path = match[3]
      %Q(scp -B -o PreferredAuthentications=publickey ) +
        %Q("#{userAt ? userAt : ''}#{host}:#{path}") +
      %Q( "#{File.join(TEMP_FOLDER,local_filename)}")
    when 's3'
      match = /s3:\/\/([^\/]+)\/(.+)/.match url
      raise DownloadError.new('invalid s3 url') unless\
	match && match.length == 3
      bucket = match[1]
      file = match[2]
      S3Curl.get_curl_command(%Q(#{S3Curl::S3CURL} #{S3Curl.access_param} -- \\
				 "http://s3.amazonaws.com/#{bucket}/#{file}" )\
			     ) + \
			       %Q( -o "#{File.join(TEMP_FOLDER,local_filename)}" \\
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
    logger.debug _command
    p = progress = nil; # to force 0% update
    IO.popen(_command) do |pipe|
      separator = case application
		  when 'axel' then "\n"
		  when 'curl' then "\r"
		  else "\n"
		  end
      pipe.each(separator) do |line|
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
    end
    raise DownloadError.new('unknown error') if $?.exitstatus != 0
    file_path = File.join(TEMP_FOLDER,local_filename)
    return File.exists?(file_path) ? file_path : false
  end

end
