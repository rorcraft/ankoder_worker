
module Transcoder
  module Tools
    class FFmpeg
      include Transcoder
      
      class << self 
        include Transcoder::Padding
        include Transcoder::Helper
      end
    
      def self.run(job)
        run_command command(job)
      end
      
      def self.run_command(command)
        progress = 0      
        IO.popen(command) do |pipe|
          pipe.each("\r") do |line|          
            parse_line(line)
            duration = parse_duration(line) if duration.nil?          
            p = parse_progress(line,duration)
            if progress_need_refresh? progress, p
              progress = p 
              block_given? ? yield(p) : print_progress(p)
              $defout.flush
            end
          end
        end
        progress_finalise

        raise TranscoderError::MediaFormatException if $?.exitstatus != 0
        raise TranscoderError::MediaFormatException unless File.exist?(job.generate_convert_filename)      
      
      rescue TranscoderError => e
        Transcoder.logger.error e.message
        Transcoder.logger.error e.backtrace.join("\n")
      end
    
      def self.command(job)
        cmd = ''
        cmd += " -y -f #{job.profile.video_format} -vcodec #{job.profile.video_codec} -r #{job.profile.video_fps} "
        cmd += " -acodec #{job.profile.audio_codec} -ab #{job.profile.audio_bitrate}k -ar #{job.profile.audio_rate} -ac #{job.profile.audio_channel} #{job.profile.extra_param} "
        # cmd += " -vhook '/home/ffmpeg/usr/local/lib/vhook/watermark.so -f #{File.join(FILE_FOLDER,@profile.watermark)}' " if download_watermark
        cmd += padding_command(job.profile, job.original_file)
        # optional params
        cmd += " -bt #{job.profile.video_bitrate}k " if job.profile.video_bitrate.to_i > 0
                                # can use S3 link directly here? if the file is public
        cmd = "#{FFMPEG_PATH} -i #{job.original_file.file_path} #{cmd} #{File.join(FILE_FOLDER, job.generate_convert_filename)} 2>&1"
        cmd
      end
    
      def self.padding_command(profile, video)
        cmd = ""
        padding_info = padding(profile.width, profile.height, video.width, video.height)
        cmd += " -padleft #{padding_info["padleft"]} " unless padding_info["padleft"].blank? 
        cmd += " -padright #{padding_info["padright"]} " unless padding_info["padright"].blank? 
        cmd += " -padtop #{padding_info["padtop"]} " unless padding_info["padtop"].blank? 
        cmd += " -padbottom #{padding_info["padbottom"]} " unless padding_info["padbottom"].blank? 
        cmd += " -s #{padding_info["result_width"]}x#{padding_info["result_height"]} "
        return cmd
      end
         
      
      private
    


    
      def self.parse_progress(line,duration)
        if line =~ /time=\s*(\d+).(\d+)/  
          if duration.nil? or duration == 0
            p = 0
          else
            p = ($1.to_i * 10 + $2.to_i) * 100 / duration
          end
          p = 100 if p > 100
          p
        else 
          0
        end
      end
    
      def self.progress_finalise
        block_given? ? yield(100) : stdout_progress(100)
      end
    
      def self.parse_line(line)
        raise TranscoderError::MediaFormatException if line =~ /frame decoding failed: Array index out of range/
        raise TranscoderError::MediaFormatException if line =~ /MV errors/
        raise TranscoderError::MediaFormatException if line =~ /Could not write header for output file/
      end

    
      def self.parse_duration(line)
        if line =~ /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{1})/m
          (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 10 + $4.to_i
        else
          nil
        end
      end

      def self.print_progress(progress)
        puts "Progress: #{progress}"
      end
    
    
    end
  end  
end
