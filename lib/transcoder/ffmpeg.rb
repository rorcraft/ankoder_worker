module Transcoder
  
  module FFmpeg


    include Transcoder::Padding

    def command(job)
      cmd = ''
      cmd += " -y -f #{job.profile.video_format} -vcodec #{job.profile.video_codec} -r #{job.profile.video_fps} "
      cmd += " -acodec #{job.profile.audio_codec} -ab #{job.profile.audio_bitrate}k -ar #{job.profile.audio_rate} -ac #{job.profile.audio_channel} #{job.profile.extra_param} "
      # cmd += " -vhook '/home/ffmpeg/usr/local/lib/vhook/watermark.so -f #{File.join(FILE_FOLDER,@profile.watermark)}' " if download_watermark
      cmd += padding_command(job.profile, job.original_file)
      # optional params
      cmd += " -bt #{job.profile.video_bitrate}k " if job.profile.video_bitrate.to_i > 0
                              # can use S3 link directly here? if the file is public
      cmd = "#{FFMPEG_PATH} -i #{job.original_file.file_path} #{cmd} #{} 2>&1"
      cmd
    # rescue Exception => e
    # logger.debug $!
    # false
    end
    
    private
    
    def padding_command(profile, video)
      cmd = ""
      padding_info = padding(profile.width, profile.height, video.width, video.height)
      cmd += " -padleft #{padding_info["padleft"]} " unless padding_info["padleft"].blank? 
      cmd += " -padright #{padding_info["padright"]} " unless padding_info["padright"].blank? 
      cmd += " -padtop #{padding_info["padtop"]} " unless padding_info["padtop"].blank? 
      cmd += " -padbottom #{padding_info["padbottom"]} " unless padding_info["padbottom"].blank? 
      cmd += " -s #{padding_info["result_width"]}x#{padding_info["result_height"]} "
      return cmd
    end
    
    
  end
  
end
