require 'hmac'
require 'hmac-sha1'
require 'errors'

class Video < ActiveResource::Base

  SUBMITTING = "submitting"
  QUEUEING = "queueing" 
  DOWNLOADING = "downloading"
  DOWNLOADED = "downloaded"
  FAILED    = "failed"
  STATUS = [SUBMITTING, QUEUEING, DOWNLOADING, DOWNLOADED, FAILED]  

  include AwsHelper
  include AWS::S3

  self.site = AR_SITE
  DEFAULT_SEC = 0
  SIZES = {:medium=>300,:small=>150, :tiny => 50}
  EXCLUDE_WHEN_SAVING = [:thumb, :thumbnail_name, :profile]

  # TODO: should put this into a module as these are common to trunk/video and worker/video
  def file_path(_filename = nil)
    filename = _filename || self.filename
    File.join(FILE_FOLDER,filename) unless filename.nil?
  end

  def set_filename
    return unless original_filename.nil?
    if !name.nil?
      self.original_filename = "#{name}"
    elsif !filename.nil?
      p "filename = #{filename}"
      self.original_filename = "#{filename}"
    end
    if name.nil? and !self.original_filename.blank?
      self.name = self.original_filename
    end
  end
    
  def read_metadata
    return unless file_exist?
    f = inspector
    %w(width height duration video? audio? audio_codec video_codec fps bitrate).each do |attr|
      eval("self.#{attr.delete('?')} = f.send(attr)") rescue false 
    end   
    self.readable = f.valid?     
    unless filename_has_container?
      raise BadVideoError.new unless f.container
      old_file_path = file_path
      extension = f.container.split(",").first
      self.filename = "#{filename}.#{extension}" 
      while File.exist?(self.file_path)
        self.filename = self.make_hashed_name
        self.filename = "#{self.filename}.#{extension}"
      end
      FileUtils.mv old_file_path, file_path
    end
  end

  def filename_has_container?
    !File.extname(self.filename).blank?
  end

  def inspector
    return unless file_exist?
    return RVideo::Inspector.new(:file => file_path, :ffmpeg_binary => FFMPEG_PATH )
  end
    
  def s3_url(option = {})
    s3_connect
    AWS::S3::S3Object.url_for(self.s3_name, S3_BUCKET, option)    
  end
  
  def s3_exist?
    s3_connect
    S3Curl.exist?(self.s3_name) 
  end
  
  def s3_name
    "#{self.id}_#{self.filename}"
  end

  def file_exist?
    File.exist?(self.file_path) rescue false
  end

  def default_sec(time = nil)
    time = Video::DEFAULT_SEC if time.nil? 
    (0 < time && time < duration_in_secs) ? time : (duration_in_secs / 2).to_i #if default secs in outside of video duration
  end

  def duration_in_secs                                                      
     duration.nil? ? 0.0 : duration.to_i / 1000.0
  end
 
  def partitioned_path(*args)
    ("%08d" % self.id).scan(/..../) + args
  end  
  
  def upload_to_s3
    TryAFewTimes.do(MAX_S3_UPLOAD_TRIES) do |i|
      increment_s3_upload_trials
      S3Curl.upload(s3_name, file_path, {"original_filename"=> original_filename})
    end
    if s3_exist?
      self.uploaded = true
      self.save
    end
  end

  def extract_filename_from_url    
    self.original_filename = URI.parse(self.source_url).path[%r{[^/]+\z}]
    self.original_filename = rand.to_s if original_filename.blank?
  end

  def make_hashed_name
    original_filename = "" unless respond_to? "original_filename"
    extract_filename_from_url  if (original_filename.blank?) and (respond_to?("source_url") and !source_url.blank?)
    Digest::SHA1.hexdigest("--#{Time.now.to_i.to_s}--#{original_filename}--#{(rand*Time.now.to_i).to_i}--")
  end

  def extract_file_information(_file_path = file_path)
    self.filename = File.basename(_file_path)
    self.size = File.size(_file_path)
  end

  def user(force = false)
    if force
      @user = User.find(self.user_id)
    else
      @user ||= User.find(self.user_id)
    end
    return @user
  end

  def logger
    @logger = RAILS_DEFAULT_LOGGER if !defined?(@logger) &&
      (defined?(RAILS_DEFAULT_LOGGER) && !RAILS_DEFAULT_LOGGER.nil?)
    @logger = ActiveRecord::Base.logger unless defined?(@logger)
    @logger = Logger.new(STDOUT) unless defined?(@logger)
    @logger
  end

  def encode(options={})
    save_attributes = self.attributes.except(*EXCLUDE_WHEN_SAVING)
    case self.class.format
    when ActiveResource::Formats[:xml]
      self.class.format.encode(
        save_attributes,
        {:root => self.class.element_name}.merge(options))
    else
      self.class.format.encode(save_attributes, options)
    end
  end

  def set_status(_status)
    put(:set_status, :status => _status)
    self.status = _status
  end

  def increment_s3_upload_trials
    self.s3_upload_trials = self.s3_upload_trials.to_i + 1
    self.save
  end

  def get_thumbnails
  end

end
