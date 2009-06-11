class Uploader

  TEMP_FOLDER = '/tmp' unless defined? TEMP_FOLDER
  USER_AGENT  = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.11)"+
    "Gecko/20071231 Firefox/2.0.0.11 Flock/1.0.5" unless defined? USER_AGENT

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
    raise UploadError.new('blank url') if url.blank?
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

  def self.download s3_url, filename
    raise UploadError.new('s3_url cannot be blank') if s3_url.blank?
    tmp_path = path(filename)
    command = %Q{\\
      curl -L -# -A "#{USER_AGENT}" "#{escape_quote URI.parse(s3_url)}" \\
      -o #{escape_quote tmp_path} 2>&1}
    logger.debug command
    error = ''
    IO.popen(command) {|pipe|
      pipe.each("\n") do |line|
        error = error + line
      end
    }
    (logger.debug error; raise UploadError.new('download from e3 failed') )if\
      $? != 0 || !File.exist?(tmp_path)
    return tmp_path
  end

  def self.command(url, local_filename, options={})
    tmp_path = path(local_filename)
    if options[:remote_filename]
      url = url + '/' if url[url.length-1] != '/'[0]
      url = url + options[:remote_filename]
    end
    case (protocol = url_protocol url)
    when 'ftp'
      if options[:username] && options[:password]
        %Q[\\
          curl -T "#{escape_quote tmp_path}" "#{escape_quote url}" \\
          -u "#{escape_quote options[:username]}:] +
          %Q[#{escape_quote options[:password]}"]
      else
        %Q[curl -T "#{escape_quote tmp_path}" "#{escape_quote url}"]
      end
    when 'sftp'
      match = /sftp:\/\/(\w+@)?([^\/]+)(\/.*)/.match url
      raise UploadError.new('invalid sftp url') unless \
        match && match.length == 4
      userAt = match[1]
      host = match[2]
      remote_path = match[3]
      %Q[scp -B -o PreferredAuthentications=publickey \\
        "#{escape_quote tmp_path}" \\
        "#{userAt ? escape_quote(userAt) : ''}#{escape_quote host}:]+
        %Q[#{escape_quote remote_path}"]
    else
      raise UploadError.new('protocol unsupported')
    end
  end

  def self.upload *args
    default_options = {:upload_url => '', :s3_url => ''}
    options = default_options.merge(args.extract_options!)
    upload_url = options[:upload_url]
    raise UploadError.new('upload url cannot be blank') if upload_url.blank?
    unless local_filename=options[:local_file_path]
      s3_url = options[:s3_url]
      local_filename = make_temp_filename
      download s3_url, local_filename
    end
    _command = command(upload_url, local_filename, options)
    logger.info _command
    error = ''
    IO.popen(_command) do |pipe|
      pipe.each("\n") do |line|
        error = error + line
      end
    end
    raise UploadError.new('unknown error') if $?.exitstatus != 0
    File.delete(path(local_filename)) unless options[:local_file_path] 
    return true
  end

end
