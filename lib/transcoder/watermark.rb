class Float
  def to_even
    self.to_i.odd? ? self.to_i + 1 : self.to_i
  end
end

module Transcoder

  class Watermark

    def self.bgcolor(profile)
      profile.watermark_transparent? ? profile.watermark_bgcolor || "808080" : "000000"
    end
    
    def self.image_size(path)
      ImageScience.with_image(path){|i|return i.width, i.height}
    end

    # params = image_width, image_height, video_width, video_height, profile.watermark_ratio
    def self.compute_result_size(iw, ih, vw, vh, ratio)
      iw, ih, vw, vh, ratio = [iw, ih, vw, vh, ratio].map(&:to_f)
      if iw/ih >= vw/vh # one rvw in 320x240
        width  = vw*ratio
        height = width*ih/iw
      else # one column in 320x240
      end
    end

  end
end
