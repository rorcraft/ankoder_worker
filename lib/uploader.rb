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

  def self.path filename
    File.join(TEMP_FOLDER, filename)
  end

  def self.escape_quote url
    raise UploadError.new('blank url') if url.blank?
    url.sub(/"/,'\"')
  end

  def self.download_from_e3 s3_url, filename
    tmp_path = path(filename)
    command = %Q{\\
      curl -L -# -A "#{USER_AGENT}" "#{escape_quote URI.parse(s3_url)}" \\
      -o #{escape_quote tmp_path} 2>&1}
    IO.popen command {|pipe| ;}
    raise UploadError.new('download from e3 failed') if\
      $? != 0 || !File.exist?(tmp_path)
    return tmp_path
  end

end
