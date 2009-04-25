class Video < ActiveResource::Base
  self.site = AR_SITE
  DEFAULT_SEC = 0
  SIZES = {:medium=>300,:small=>150, :tiny => 50}

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
      eval("self.#{attr.delete('?')} = f.send(attr)")   rescue false 
    end   
    readable = f.valid? 
  end

  def inspector
    return unless file_exist?
    return RVideo::Inspector.new(:file => file_path, :ffmpeg_binary => FFMPEG_PATH )
  end
    
  def s3_url(option = {})
    AWS::S3::S3Object.url_for(self.s3_name, S3_BUCKET, option)    
  end
  
  def s3_exist?
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
     duration.nil? ? 0 : (duration / 1000).to_i
  end
 
  def ffmpeg_thumbnail(time= nil)
    time = default_sec time
    FileUtils.mkdir_p File.dirname(self.thumbnail_full_path(time))    
    # sleep(1) # ?
    command = "#{FFMPEG_PATH} -i #{self.file_path} -y -f image2 -ss #{time} -t 0.001 #{self.thumbnail_full_path(time)}"
    # logger.info command
    f = IO.popen(command)
    f.close
  end

  def partitioned_path(*args)
    ("%08d" % self.id).scan(/..../) + args
  end  
  
  def generate_thumbnails(time=nil)
    return unless file_exist?
    time = default_sec(time)    
    
    ffmpeg_thumbnail(time)
    
    Video::SIZES.each do |key,value|
      image_resize(time, key, value)
    end
  end
  
  def upload_thumbnails_to_s3(time=nil) 
    return unless file_exist?
    time = default_sec(time)    
        
    #s3_connect
    #AWS::S3::S3Object.store(thumbnail_name(time), open(self.thumbnail_full_path(time)), ::S3_BUCKET ,  :access => :public_read)
    S3Curl.upload(thumbnail_name(time), thumbnail_full_path(time))    
    Video::SIZES.each { |key,value|
      count = 0
      begin
        #AWS::S3::S3Object.store(thumbnail_name(time,key), open(self.thumbnail_full_path(time,key)), ::S3_BUCKET ,  :access => :public_read)
        S3Curl.upload(thumbnail_name(time, key), thumbnail_full_path(time, key))    
      rescue
        count += 1
        retry if count < 3
        raise
      end
    }
    self.thumbnail_uploaded = true
    self.save
  end
  
  def upload_to_s3
    S3Curl.upload(s3_name, file_path, {"original_filename"=> original_filename})    
    if s3_exist?
      self.thumbnail_uploaded = true
      self.save
    end
  end
  
  def thumbnail_path(time=nil, size = nil)
    File.join  THUMBNAIL_FOLDER, *partitioned_path(thumbnail_name(time,size)) 
  end

  def thumbnail_full_path(time=nil, size = nil)    
    "#{PUBLIC_FOLDER}/#{thumbnail_path(time,size)}"
  end

  # TODO: Need to create models for thumbnails.  
  def thumbnail_name(time=nil,size = nil)
    time = default_sec time
    size = default_thumb_size size
  
    filename + (size.nil? ? ".#{time}.jpg" : ".#{time}.#{size}.jpg")
  end

  def default_thumb_size(size)                                              
    Video::SIZES.has_key?(size) ? size : "small"
  end

  def image_resize(time, size, width)
    # MiniMagick had problems with mod_rails
    # image = MiniMagick::Image.new thumbnail_full_path(time)
    # image.resize width
    # image.write output
    # logger.info "image_resize"
    # logger.info "#{size}, #{width}"
    #trying imagescience
    ImageScience.with_image(thumbnail_full_path(time)) do |img|
      img.thumbnail(width) do |thumb|
        thumb.save thumbnail_full_path(time,size)
      end
    end
  end

end
