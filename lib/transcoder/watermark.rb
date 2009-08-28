class Numeric
  def to_even
    to_i.odd? ? to_i + 1 : to_i
  end
end

module Transcoder
  class WatermarkError < TranscoderError; end

  class Watermark
    extend Padding

    def self.generate(job)
      temp = File.join(Uploader::TEMP_FOLDER, Uploader.make_temp_filename(".jpg"))
      cmd = command(job, temp)
      Rails.logger.debug(cmd)
      `#{cmd}`
      raise WatermarkError unless $?.exitstatus == 0
      File.delete(job.watermark_image)
      job.watermark_image = temp
    end

    def self.command(job, temp)
      iw, ih = image_size(job.watermark_image)
      vw, vh = get_result_video_size(job)
      ww, wh = watermark_size(iw, ih, vw, vh, job.profile.watermark_ratio)
      top, bottom, left, right = paddings(ww, wh, vw, vh, job.profile.watermark_top_ratio, job.profile.watermark_left_ratio)
      cmd = "#{FFMPEG_PATH} -i #{job.watermark_image} -y -s #{ww}x#{wh} -padcolor #{job.profile.watermark_effective_bgcolor}"
      [[top,"padtop"],[left,"padleft"],[bottom,"padbottom"],[right,"padright"]].each do |value, option|
        cmd += " -#{option} #{value}" if value > 0 end
      cmd += " #{temp}"
      return cmd
    end
    
    def self.image_size(path)
      ImageScience.with_image(path){|i|return i.width, i.height}
    end

    def self.get_result_video_size(job)
      diminfo = get_dim_info(job)
      if !job.profile.add_padding? && job.profile.keep_aspect?
        return diminfo["result_width"], diminfo["result_height"]
      else
        return diminfo["profile_width"], diminfo["profile_height"]
      end
    end

    # params = image_width, image_height, video_width, video_height
    def self.watermark_size(iw, ih, vw, vh, watermark_ratio)
      return compute_result_size(iw, ih, vw, vh, watermark_ratio)
    end

    # params = watermark_width, watermark_height, video_width, video_height, profile.watermark_top_ratio, profile.watermark_left_ratio
    def self.paddings(ww, wh, vw, vh, top_ratio, left_ratio)
      top    = (vh*top_ratio  - wh/2.0).to_even
      left   = (vw*left_ratio - ww/2.0).to_even
      right  = vw - ww - left
      bottom = vh - wh - top
      return top, bottom, left, right
    end

    # params = image_width, image_height, video_width, video_height, profile.watermark_ratio
    def self.compute_result_size(iw, ih, vw, vh, ratio)
      iw, ih, vw, vh, ratio = [iw, ih, vw, vh, ratio].map(&:to_f)
      if iw/ih >= vw/vh # one rvw in 320x240
        width  = vw*ratio
        height = width*ih/iw
      else # one column in 320x240
        height = vh*ratio
        width = height*iw/ih
      end
      return width.to_even, height.to_even
    end

  end
end
