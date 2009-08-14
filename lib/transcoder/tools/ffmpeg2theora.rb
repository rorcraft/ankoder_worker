module Transcoder
  module Tools
    class FFmpeg2theora
      include Transcoder

      class << self
        include Transcoder::Padding
        include Transcoder::Helper
      end

      def self.run(job)
        run_command(command(job),job) do |progress|
          job.convert_progress = progress
          job.save
        end
      end

      def self.raise_media_format_exception
        raise TranscoderError::MediaFormatException.new(@ffmpeg_output)
      end

      def self.run_command(command,job)
        progress = 0
        IO.popen(command) do |pipe|
          duration = nil
          @ffmpeg_output = ""
          pipe.each("\r") do |line|
            @ffmpeg_output += line + "\n"
            parse_line(line)
            duration = parse_duration(line) if duration.nil?
            p = parse_progress(line,duration,job)
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

      end

      def self.command(job)
        dim_info = get_dim_info(job)

        cmd = ''

        cmd += video_command(dim_info, job)
        cmd += audio_command(job)

        cmd += " --speedlevel 1" # balanced way of speeding up generation

        temp_file_path = "#{Time.now.to_i}_#{job.generate_convert_filename}"
        temp_file_path_as_ogv = "#{Time.now.to_i}_#{job.generate_convert_filename}.ogv"
        cmd = "#{FFMPEG2THEORA_PATH} #{job.original_file.file_path} #{cmd} -o #{File.join(FILE_FOLDER, temp_file_path_as_ogv)} 2>&1"

        # send back to ffmpeg if: the audio codec is not vorbis OR container is not ogv
        if uses_ffmpeg_to_generate(job) # dirty but works
          Transcoder.logger.debug "processing in ffmpeg"
          cmd += ";#{FFMPEG_PATH} -i #{File.join(FILE_FOLDER, temp_file_path_as_ogv)}"
          cmd += " -vcodec copy"

          cmd += " -i #{job.original_file.file_path}"
          cmd += FFmpeg.audio_command(job)

          cmd += " -y -f #{job.profile.video_format}"
          cmd += " #{File.join(FILE_FOLDER, temp_file_path)} 2>&1"
          cmd += ";rm -f #{File.join(FILE_FOLDER, temp_file_path_as_ogv)}"
        else
          cmd += ";mv #{File.join(FILE_FOLDER, temp_file_path_as_ogv)} #{File.join(FILE_FOLDER, temp_file_path)}"
        end
        cmd += ";mv #{File.join(FILE_FOLDER, temp_file_path)} #{File.join(FILE_FOLDER, job.generate_convert_filename)}"
        Transcoder.logger.debug cmd
        cmd
      end

      private

      def self.video_command(dim_info, job)
        cmd = ''

        cmd += " -F #{job.profile.video_fps}" unless job.profile.video_fps.blank?
        # bitrate
        cmd += " -V #{job.profile.video_bitrate}k " if job.profile.video_bitrate.to_i > 0
        if job.profile.width.to_i > 0
          cmd += " -x #{dim_info["profile_width"]} -y #{dim_info["profile_height"]}"
        end
        cmd
      end

      def self.audio_command(job)
        # only generate vorbis audio if the format required is vorbis and the video is in fact og-something
        if job.profile.audio_channel.to_i > 0 && !job.profile.audio_codec.blank? && job.profile.audio_codec =~ /vorbis/i && job.profile.video_format =~ /og?/i
          cmd = ''
          cmd += " -H #{job.profile.audio_rate}" unless job.profile.audio_rate.blank?
          cmd += " -A #{job.profile.audio_bitrate}k" unless job.profile.audio_bitrate.blank?
          cmd += " -c #{job.profile.audio_channel}" unless job.profile.audio_channel.blank?
        else
          " --noaudio" # we don't need the noise
        end
      end

      def self.parse_progress(line,duration,job)
        p = 0
        unless duration.nil? or duration == 0
          if uses_ffmpeg_to_generate(job)
            p = parse_theora_time(line)
            p = p * 60 / duration if p
            if line =~ /time=\s*(\d+).(\d+)/
              p = ($1.to_i * 1000 + $2.to_i.to_f) * 40 / duration / 2 + 60
            end
          else
            p = parse_theora_time(line)
            p = p * 100 / duration if p
          end
          p ||= 0
          p = 100 if p > 100
          p.to_i
        end
        return p
      end

      def self.progress_finalise
        block_given? ? yield(100) : stdout_progress(100)
      end

      def self.parse_line(line)
        raise_media_format_exception if line =~ /frame decoding failed: Array index out of range/
        raise_media_format_exception if line =~ /MV errors/
        raise_media_format_exception if line =~ /Could not write header for output file/
        raise_media_format_exception if line =~ /does not exist or has an unknown data format/
      end


      def self.parse_duration(line)
        if line =~ /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{2})/m
          (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 1000 + $4.to_i
        else
          nil
        end
      end

      def self.parse_theora_time(line)
        if line =~ /(\d{1}):(\d{2}):(\d{2}).(\d{2}) audio/m
          (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 1000 + $4.to_i
        else
          nil
        end
      end

      def self.uses_ffmpeg_to_generate(job)
        !(job.profile.video_format =~ /og?/i)
      end

    end
  end
end
