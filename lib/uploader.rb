class Uploader

  TEMP_FOLDER = '/tmp' unless defined? TEMP_FOLDER
  USER_AGENT  = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11)"+
    "Gecko/20071231 Firefox/2.0.0.11 Flock/1.0.5" unless defined? USER_AGENT

  def self.curl_flags
    %Q[ \\
      -v -L -Y 100 \\
      --connect-timeout #{TimeoutDetector::DETECTOR_TIMEOUT_SEC} \\
      -y #{TimeoutDetector::DETECTOR_TIMEOUT_SEC} \\
    ]
  end

  class UploadError < RuntimeError; end

  def self.logger
    @@logger = RAILS_DEFAULT_LOGGER if !defined?(@@logger) &&
      (defined?(RAILS_DEFAULT_LOGGER) && !RAILS_DEFAULT_LOGGER.nil?)
    @@logger = ActiveRecord::Base.logger unless defined?(@@logger)
    @@logger = Logger.new(STDOUT) unless defined?(@@logger)
    @@logger
  end

  def self.url_protocol url
    match=/^(\w+):\/\//.match(url)
    match ? match[1] : nil
  end

  def self.path filename
    if filename[0] == '/'[0]
      filename
    else
      File.join(TEMP_FOLDER, filename)
    end
  end

  def self.escape_quote url
    url.to_s.sub(/"/,'\"')
  end

  def self.make_temp_filename
    filename = nil
    loop do
      filename = "uploader_temp_file#{rand*Time.now.to_i}"
      break unless File.exist?(path(filename))
    end
    return filename
  end

  def self.command(url, local_filename, options={})
    tmp_path = path(local_filename)
    protocol = url_protocol url
    if url =~ /s3\.amazonaws\.com/ || options[:remote_filename] && protocol!='http'
      url = url + '/' if url[url.length-1] != '/'[0]
      url = url + options[:remote_filename]
    end
    case protocol
    when 'ftp'
      if options[:username] && options[:password]
        return %Q[curl #{curl_flags}\\
          -T "#{escape_quote tmp_path}" "#{escape_quote url}" \\
          -u "#{escape_quote options[:username]}:] +
          %Q[#{escape_quote options[:password]}" 2>&1]
      else
        return %Q[curl #{curl_flags}\\
          -T "#{escape_quote tmp_path}" "#{escape_quote url}" 2>&1]
      end
    when 'sftp'
      match = /sftp:\/\/(\w+@)?([^\/]+)(\/.*)/.match url
      raise UploadError.new('invalid sftp url') unless \
        match && match.length == 4
      userAt = match[1]
      host = match[2]
      remote_path = match[3]
      return %Q[scp -B -o PreferredAuthentications=publickey \\
        "#{escape_quote tmp_path}" \\
        "#{userAt ? escape_quote(userAt) : ''}#{escape_quote host}:]+
        %Q[#{escape_quote remote_path}" 2>&1]
    when 'http','s3'
      #handles s3 as a special case
      if url =~ /s3\.amazonaws\.com/
        s3_file = nil
        unless url =~ %r[http://s3\.amazonaws\.com/[^/]+(/(.+))?]
          array = url.split /s3\.amazonaws\.com\/?/
            s3_file = array[1]
        else
          s3_file = $2
        end
        if !s3_file && url[url.length-1] != '/'[0]
          url = url + '/'
        end
        return S3Curl.get_curl_command(
          %Q[#{S3Curl::S3CURL} #{S3Curl.access_param} --put="#{tmp_path}"\
             #{"--acl public-read" if options[:destination_s3_public]}\
            -- "#{url}#{s3_file ? '' : options[:remote_filename]}"]) +
            " #{curl_flags} -L -v 2>&1"
      elsif url =~ %r[^s3://]
        # alternative s3 url
        match = /s3:\/\/([^\/]+)\/?([^\?]*)/.match url
        raise UploadError.new('invalid s3 url') unless\
          match && match.length >= 2
        bucket = match[1] + '/'
        file = match[2]
        return S3Curl.get_curl_command(
          %Q[#{S3Curl::S3CURL} #{S3Curl.access_param} --put="#{tmp_path}"\
             #{"--acl public-read" if options[:destination_s3_public]}\
            -- "http://s3.amazonaws.com/#{bucket}#{file.blank? ? options[:remote_filename] : file}"]) +
            " #{curl_flags}  2>&1"
      else
        # http multipart
        return %Q[curl #{curl_flags}\\
          -F "file=@#{escape_quote tmp_path}" \\
          -F "video_id=#{escape_quote options[:video_id]}" \\
          -F "thumbnail_url=#{escape_quote options[:thumbnail_url]}" \\
          "#{url}" 2>&1]
      end 

    else
      raise UploadError.new('protocol unsupported')
    end
  end

  def self.url_protocol url
    Downloader.url_protocol url
  end

  def self.upload *args
    default_options ={}
    options = default_options.merge(args.extract_options!)
    upload_url = options[:upload_url]
    local_filename=options[:local_file_path]
    raise UploadError.new('upload url cannot be blank') if upload_url.blank?
    raise UploadError.new('local filename cannot be blank')if local_filename.blank?
    
    _command = command(upload_url, local_filename, options)
    application = _command.slice /\S+/
    logger.info _command
    output = ''
    IO.popen(_command) do |pipe|
      error_detector = ErrorDetector.new(
        application, url_protocol(upload_url)
      )
      begin
        pipe.each("\n") do |line|
          output = output + line
          error_detector.check_for_error line
        end
      rescue Exception => e # to catch non-standard errors too
        # kill the uploader process, else it may hang forever
        `kill -9 #{pipe.pid}`
        # rethrow exception
        raise e
      end
    end
    if $?.exitstatus != 0
      logger.debug output
      raise RuntimeError.new('unknown error') 
    end
    File.delete(path(local_filename)) unless options[:local_file_path] 
    return true
  end

end
