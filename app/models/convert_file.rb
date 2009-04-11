class ConvertFile < Video
  self.site = AR_SITE
  
  def file_exist?
    File.exist?(file_path) rescue false
  end
    
  def file_path(_filename = nil)
    _filename ||= filename
    File.join(::FILE_FOLDER,_filename) if _filename
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

end
