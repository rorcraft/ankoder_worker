module Transcoder

  module Padding
    
    # split padding into symmetric halves
    # current: the width/height needed to be altered
    def split_padding video_current, video_other, profile_current, profile_other

      #profile_current = 2* ( after/2 )+ padding *2

      ratio = video_current.to_f / video_other.to_f

      after_f = after = profile_other * ratio

      after = float_to_even_int after_f
      after = 2 if after <= 0

      if ((profile_current - after)/2).to_i.odd?
        if after > after_f
          after -= 2
        else
          after += 2
        end
      end
      pad = (profile_current - after) / 2

      # fallback if really really something awful occurs (which should not happen anyway)
      pad = 0 if pad < 0
      after = profile_current if after > profile_current

      return pad, pad, after #padding must be even number themselves.
    end

    def float_to_even_int(float)
      if float % 1 > 0.5000
        result = float.ceil
        result -= 1 if result.odd?
      else
        result = float.floor
        result += 1 if result.odd?
      end
      result
    end
    # turns odd numbers into even & even ones into themselves
    def even_size(size, increase = true)
      size = (size.to_i rescue 240)
      size += 1 if size.odd? && increase
      size -= 1 if size.odd? && (increase != true)
      size
    end

    def padding(profile_width, profile_height, video_width, video_height)
      return {"result_width" => 320, "result_height" => 240} if profile_width.to_i <= 0 && video_width.to_i <= 0
      return {"result_width" => video_width, "result_height" => video_height} if profile_width.to_i <= 0 && profile_height.to_i <= 0
      return {"result_width" => profile_width, "result_height" => profile_height} if video_width.to_i < 0 or video_height.to_i < 0
      return {"result_width" => profile_width, "result_height" => even_size(profile_width * video_height / video_width) } if profile_width.to_i > 0 && profile_height.to_i == 0
      return {"result_width" => even_size(profile_height * video_width / video_height), "result_height" => profile_height } if profile_width.to_i == 0 && profile_height.to_i > 0
      return {"result_width" => profile_width, "result_height" => profile_height } if video_width.to_f / video_height.to_f == profile_width.to_f / profile_height.to_f

      result = {}
      %w{profile_width profile_height video_width video_height}.each do |measure|
        eval "#{measure} = #{measure}.to_f"
      end
      ratio_width , ratio_height  = profile_width / video_width , profile_height / video_height
      result_width, result_height = profile_width, profile_height

      ratio = even_size(profile_width).to_f / even_size(profile_height).to_f
      video_ratio = even_size(video_width).to_f / even_size(video_height).to_f

      if (ratio > 1.555)
        result["aspect_ratio"] = "16:9"
        ratio_width = 16
        ratio_height = 9
      else
        result["aspect_ratio"] = "4:3"
        ratio_width = 4
        ratio_height = 3
      end

      if profile_height == 0 #auto get height
        result_height = profile_width * video_height / video_width.to_i
      else
        # pad top and bottom; profile too high
        if profile_width*video_height < profile_height*video_width
          result["padtop"], result["padbottom"], result_height = split_padding(video_height, video_width, profile_height, profile_width)
        # pad left and right; profile too wide
        elsif profile_width*video_height > profile_height*video_width
          result["padleft"], result["padright"], result_width = split_padding(video_width, video_height, profile_width, profile_height)
        end
      end

      result["result_width"], result["result_height"] = result_width, result_height

      return result
    end


  end

end
