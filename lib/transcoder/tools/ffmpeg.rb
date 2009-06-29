
module Transcoder
  module Tools
    class FFmpeg
      include Transcoder
      
      class << self 
        include Transcoder::Padding
        include Transcoder::Helper
      end
    
      def self.run(job)
        run_command command(job) do |progress|
          job.convert_progress = progress
          job.save
        end 
      end
      
      def self.run_command(command)
        progress = 0      
        IO.popen(command) do |pipe|
          duration = nil
          pipe.each("\r") do |line|          
            parse_line(line)
            duration = parse_duration(line) if duration.nil?          
            p = parse_progress(line,duration)
            if p >= progress 
              progress = p 
              block_given? ? yield(p) : stdout_progress(p)
              $defout.flush
            end
          end
        end
        progress_finalise

        if $?.exitstatus != 0
          Transcoder.logger.error command
          raise TranscoderError::MediaFormatException
        else
          # to ensure the convert is 100 is the conversion is success
          progress = 100 
          block_given? ? yield(progress) : stdout_progress(progress)
        end

        
        # Fixme: When doing 2-pass the output is not the job.generate_convert_filename
        # not supporting 2-pass for now.
#        raise TranscoderError::MediaFormatException unless File.exist?(File.join(FILE_FOLDER, job.generate_convert_filename))
      
      rescue TranscoderError => e
        Transcoder.logger.error e.message
        Transcoder.logger.error e.backtrace.join("\n")
      end
    
      def self.command(job)
        cmd = ''
        cmd += " -y -f #{job.profile.video_format} -vcodec #{job.profile.video_codec}"
        cmd += " -r #{job.profile.video_fps}" unless job.profile.video_fps.blank?
        cmd += " -acodec #{job.profile.audio_codec}"
        cmd += " -ab #{job.profile.audio_bitrate}k" unless job.profile.audio_bitrate.blank?
        cmd += " -ar #{job.profile.audio_rate}" unless job.profile.audio_rate.blank?
        cmd += " -ac #{job.profile.audio_channel}" unless job.profile.audio_channel.blank?

        # cmd += " -vhook '/home/ffmpeg/usr/local/lib/vhook/watermark.so -f #{File.join(FILE_FOLDER,@profile.watermark)}' " if download_watermark

        # bitrate
        if job.profile.keep_quality?
          cmd += " -sameq " 
        elsif job.profile.video_bitrate.to_i > 0
          cmd += " -b #{job.profile.video_bitrate}k " 
        end
        
        if job.profile.add_padding?
          cmd += padding_command(job.profile, job.original_file) 
        elsif job.profile.width.to_i > 0
          cmd += "-s #{job.profile.width}x#{job.profile.height}"
        end          
                
        cmd += " #{job.profile.extra_param}" # can use S3 link directly here? if the file is public
        temp_file_path = "#{Time.now.to_i}#{job.generate_convert_filename}"
        cmd = "#{FFMPEG_PATH} -i #{job.original_file.file_path} #{cmd} #{File.join(FILE_FOLDER, temp_file_path)} 2>&1"
        cmd += ";mv #{File.join(FILE_FOLDER, temp_file_path)} #{File.join(FILE_FOLDER, job.generate_convert_filename)}"
        Transcoder.logger.debug cmd
        cmd
      end
    
      def self.padding_command(profile, video)        
        cmd = ""
        padding_info = padding(profile.width, profile.height, video.width, video.height)
        cmd += " -padleft #{padding_info["padleft"]} " unless padding_info["padleft"].blank? 
        cmd += " -padright #{padding_info["padright"]} " unless padding_info["padright"].blank? 
        cmd += " -padtop #{padding_info["padtop"]} " unless padding_info["padtop"].blank? 
        cmd += " -padbottom #{padding_info["padbottom"]} " unless padding_info["padbottom"].blank? 
        cmd += " -aspect #{padding_info["aspect_ratio"]} " unless padding_info["aspect_ratio"].blank? 
        cmd += " -s #{padding_info["result_width"]}x#{padding_info["result_height"]} "
        return cmd
      end
         
         
      # def create_thumbnail( time = nil, sizes = Video::SIZES)
      #   return unless file_exist?
      #   time = default_sec(time)    
      #     
      #   ffmpeg_thumbnail(time)
      #     
      #   sizes.each do |key,value|
      #     image_resize(time, key, value)
      #   end
      #     
      #   if S3_ON
      #     s3_connect
      #     AWS::S3::S3Object.store(thumbnail_name(time), open(self.thumbnail_full_path(time)), ::S3_BUCKET ,  :access => :public_read)
      #     
      #     sizes.each { |key,value|
      #       count = 0
      #       begin
      #         AWS::S3::S3Object.store(thumbnail_name(time,key), open(self.thumbnail_full_path(time,key)), ::S3_BUCKET ,  :access => :public_read)
      #       rescue
      #         count += 1
      #         retry if count < 3
      #         raise
      #       end
      #     }
      #     self.thumbnail_uploaded = true
      #   end
      # end

      
      private
    


    
      def self.parse_progress(line,duration)
        if line =~ /time=\s*(\d+).(\d+)/  
          if duration.nil? or duration == 0
            p = 0
          else
            p = ($1.to_i * 1000 + $2.to_i.to_f) * 100 / duration
          end
          p = 100 if p > 100
          p.to_i
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
        if line =~ /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{2})/m
          (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 1000 + $4.to_i
        else
          nil
        end
      end

    
    
    end
  end  
end
