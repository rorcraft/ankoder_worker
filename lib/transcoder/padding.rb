module Transcoder

  module Padding
    
    def split_padding length
      pad1 = pad2 = even_size(length)/2
      return even_size(pad1), even_size(pad2) #padding must be even number themselves.
    end 

    def even_size(size)
      size = size.to_i 
      size += 1 if size.odd?
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
          # pad top and bottom 
          if ratio_height * video_width / ratio_width > video_height 
            result_height = even_size profile_width / video_ratio
            result["padtop"], result["padbottom"] = split_padding(-profile_height + result_height)
          # pad left and right
          elsif ratio_width * video_height / ratio_height> video_width 
            result_width = even_size profile_height * video_ratio
            result["padleft"], result["padright"] = split_padding(-profile_width + result_width) 
          end                                    
      end
      
      result["result_width"], result["result_height"] = even_size(result_width), even_size(result_height)
      
      return result 
    end
    
   
  end

end
