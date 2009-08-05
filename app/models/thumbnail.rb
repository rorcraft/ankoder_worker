class Thumbnail < ActiveResource::Base
  self.site = AR_SITE
  attr_accessor :video

  def file_path
    File.join FILE_FOLDER, filename
  end

  def size
    "#{width}x#{height}"
  end

  def partitioned_path(*args)
    ("%08d" % video_id).scan(/..../) + args
  end

  def spawn
    cmd = self.class.command :input => video.file_path,
      :output => file_path,
      :size   => size,
      :time   => time
    `#{cmd}`
    if File.exist?(file_path)
      self.save
    end
  end

  # class methods
  #
  # params: video, width, height, time
  # usage: Thumbnail.generate convert_file, :time => 199.7
  def self.generate *argv
    options = argv.extract_options!
    video = argv.first
    
    options[:input] ||= video.file_path
    thumb = self.new(
      { :video_id => video.id,
        :width    => (width  = options[:width]  || video.width),
        :height   => (height = options[:height] || video.height),
        :time     => (time   = options[:time]   || video.duration_in_secs/2.0),
        :filename => "#{video.id}-#{time}-#{width}x#{height}.png"
    })
    thumb.video = video
    thumb.spawn
    return thumb
  end

  CMD_OPT = {
    :time       => "-ss",
    :input      => "-i",
    :size       => "-s",
    :output     => ""
  }
  def self.command options
    opt = lambda{|o|options[o] ? "#{CMD_OPT[o]} #{options[o]}" : ""}
    "#{FFMPEG_PATH} #{opt.call :time} #{opt.call :input} -y -an -vframes 1 -vcodec png #{opt.call :size} #{opt.call :output} > /dev/null 2> /dev/null"
  end

end
