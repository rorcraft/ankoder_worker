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

      def self.raise_media_format_exception
        raise TranscoderError::MediaFormatException.new(@ffmpeg_output)
      end

      def self.run_command(command)
        progress = 0
        IO.popen(command) do |pipe|
          duration = nil
          @ffmpeg_output = ""
          pipe.each("\r") do |line|
            @ffmpeg_output += line + "\n"
            parse_line(line)
            duration = parse_duration(line) if duration.nil?
            p = parse_progress(line,duration)
            if p >= progress && progress_need_refresh?(progress, p)
              progress = p 
              block_given? ? yield(p) : stdout_progress(p)
              $defout.flush
            end
          end
        end
        progress_finalise

        if $?.exitstatus != 0
          Transcoder.logger.error command
          raise_media_format_exception
        else
          # to ensure the convert is 100 is the conversion is success
          progress = 100 
          block_given? ? yield(progress) : stdout_progress(progress)
        end

        # FIXME: When doing 2-pass the output is not the job.generate_convert_filename
        # not supporting 2-pass for now.
#        raise TranscoderError::MediaFormatException unless File.exist?(File.join(FILE_FOLDER, job.generate_convert_filename))
      end

      def self.preprocess(job)
        `#{preprocess_command(job)}`
      end

      # this mainly is ued to deal with theora's not being able to do padding and video triming
      def self.preprocess_command(job)
        dim_info = get_dim_info(job)

        cmd = ''
        cmd += " -y "

        cmd += " -f avi -vcodec huffyuv" # is it really raw?
        cmd += " -r #{job.profile.video_fps}" unless job.profile.video_fps.blank?
        cmd += " -acodec pcm_s16le"

        # trimming
        cmd += trimming_command(job.profile, job.original_file)

        cmd += size_command(dim_info, job)
        cmd += audio_command(job)
        if job.profile.add_padding?
          cmd += padding_command(dim_info)
        end

        cmd += " #{job.profile.extra_param}" # can use S3 link directly here? if the file is public
        temp_file_path = "#{Time.now.to_i}#{job.generate_convert_filename}"
        cmd = "#{FFMPEG_PATH} -i #{job.original_file.file_path} #{cmd} #{File.join(FILE_FOLDER, temp_file_path)} 2>&1"
        cmd += " && mv #{File.join(FILE_FOLDER, temp_file_path)} #{job.original_file.file_path}"
        Transcoder.logger.debug cmd
        cmd

      end

      def self.command(job)
        dim_info = get_dim_info(job)

        cmd = ""
        cmd += " -y "

        cmd += " -f #{job.profile.video_format}"
        cmd += video_command(dim_info, job)
        cmd += audio_command(job)

        # trimming
        cmd += trimming_command(job.profile, job.original_file)

        # bitrate
        if job.profile.video_bitrate.to_f > 0.0
          cmd += " -b #{job.profile.video_bitrate}k -bt #{job.profile.video_bitrate.to_f/15.0}k "
        else
          cmd += " -sameq "
        end

        if job.profile.add_padding?
          cmd += padding_command(dim_info) 
        end

        cmd += " #{job.profile.extra_param}" # can use S3 link directly here? if the file is public
        temp_file_path = "#{Time.now.to_i}#{job.generate_convert_filename}"
        cmd = "#{FFMPEG_PATH} -i #{job.original_file.file_path} #{cmd} #{File.join(FILE_FOLDER, temp_file_path)} 2>&1"
        cmd += ";mv #{File.join(FILE_FOLDER, temp_file_path)} #{File.join(FILE_FOLDER, job.generate_convert_filename)}"
        Transcoder.logger.debug cmd
        cmd
      end

      private

      def self.trimming_command(profile,video)
        current_duration = video.duration.nil? ? 0 : (video.duration.to_i / 1000)

        # there is no more time, so give zero length video
        return ' -t 0' if (profile.trim_begin.to_i > current_duration)

        cmd = ''
        cmd += " -ss #{profile.trim_begin}" unless profile.trim_begin.to_i < 1
        cmd += " -t #{profile.trim_end}" unless profile.trim_end.to_i < 1

        cmd
      end

      def self.video_command(dim_info, job)
        unless job.profile.video_codec.blank?
          cmd = ""
          cmd += " -vcodec #{job.profile.video_codec}"
          cmd += " -r #{job.profile.video_fps}" unless job.profile.video_fps.blank?
          size_command(dim_info, job)
        else
          " -vn"
        end
      end

      def self.size_command(dim_info,job)
        cmd = ""
        if job.profile.add_padding? || job.profile.keep_aspect?
          cmd += " -s #{dim_info["result_width"]}x#{dim_info["result_height"]} "
        else
          cmd += " -s #{dim_info["profile_width"]}x#{dim_info["profile_height"]} "
        end
        cmd += " -aspect #{dim_info["aspect_ratio"]} "
      end

      def self.padding_command(dim_info)
        cmd = ""
        cmd += " -padleft #{dim_info["padleft"]} " unless dim_info["padleft"].blank? 
        cmd += " -padright #{dim_info["padright"]} " unless dim_info["padright"].blank?
        cmd += " -padtop #{dim_info["padtop"]} " unless dim_info["padtop"].blank? 
        cmd += " -padbottom #{dim_info["padbottom"]} " unless dim_info["padbottom"].blank?
        return cmd
      end

      def self.audio_command(job)
        if job.profile.audio_channel.to_i > 0
          cmd = ""
          cmd += " -acodec #{job.profile.audio_codec}" unless job.profile.audio_codec.blank?
          cmd += " -ab #{job.profile.audio_bitrate}k" unless job.profile.audio_bitrate.blank?
          cmd += " -ar #{job.profile.audio_rate}" unless job.profile.audio_rate.blank?
          cmd += " -ac #{job.profile.audio_channel}" unless job.profile.audio_channel.blank?
        else
          " -an"
        end
      end

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
        raise_media_format_exception if line =~ /frame decoding failed: Array index out of range/
        raise_media_format_exception if line =~ /MV errors/
        raise_media_format_exception if line =~ /Could not write header for output file/
        raise_media_format_exception if line =~ /maybe incorrect parameters such as bit_rate, rate, width or height/
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
