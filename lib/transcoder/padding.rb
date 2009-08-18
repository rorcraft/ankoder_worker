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

    def get_dim_info(job)
      padding(job.profile.width,job.profile.height,job.original_file.width,job.original_file.height,job.profile.add_padding?,job.profile.keep_aspect?)
    end

    def padding(profile_width, profile_height, video_width, video_height, add_padding=true, keep_aspect=false)
      result = {}
      profile_width, profile_height, video_width, video_height = [profile_width, profile_height, video_width, video_height].map(&:to_f)
      profile_width, profile_height =
        case [profile_width > 0.0, profile_height > 0.0]
        when [false, false] then [video_width, video_height]
        when [false, true ] then [even_size(profile_height*video_width/video_height),profile_height]
        when [true , false] then [profile_width, even_size(profile_width*video_height/video_width)]
        when [true , true ] then [profile_width, profile_height]
        end
      profile_width, profile_height = 320.0, 240.0 if profile_width <= 0.0 || profile_height <= 0.0

      result_width, result_height = profile_width, profile_height
      # pad top and bottom; profile too high
      if profile_width*video_height < profile_height*video_width
        result["padtop"], result["padbottom"], result_height = split_padding(video_height, video_width, profile_height, profile_width)
      # pad left and right; profile too wide
      elsif profile_width*video_height > profile_height*video_width
        result["padleft"], result["padright"], result_width = split_padding(video_width, video_height, profile_width, profile_height)
      end

      result["result_width"], result["result_height"] = result_width.to_i, result_height.to_i
      result["profile_width"],result["profile_height"]= profile_width.to_i,profile_height.to_i
      if add_padding || !keep_aspect
        result["aspect_ratio"] = "#{result["result_width"]+result["padleft"].to_i+result["padright"].to_i}:#{result["result_height"]+result["padtop"].to_i+result["padbottom"].to_i}"
      else
        result["aspect_ratio"] = "#{result["result_width"]}:#{result["result_height"]}"
      end

      return result
    end

  end

end
