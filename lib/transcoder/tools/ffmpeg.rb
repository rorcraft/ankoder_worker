module Transcoder
  module Tools
    class FFmpeg
      include Transcoder

      class << self 
        attr_reader :ffmpeg_output
        include Transcoder::Padding
        include Transcoder::Helper
      end

      def self.run(job)
        run_command(command(job), job.profile) do |progress|
          job.convert_progress = progress
          job.save rescue nil
        end
      end

      def self.raise_media_format_exception
        raise TranscoderError::MediaFormatException.new(@ffmpeg_output)
      end

      def self.run_command(command, profile)
        progress = 0
        IO.popen(command) do |pipe|
          duration = nil
          @ffmpeg_output = ""
          pipe.each("\r") do |line|
            @ffmpeg_output += line + "\n"
            parse_line(line)
            duration = parse_duration(line, profile) if duration.nil?
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
        cmd += padding_command(dim_info) if job.profile.add_padding?


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

        # x264 options
        if job.profile.video_codec == "libx264"
          cmd += x264_command(job.profile.x264_options)
          cmd += " -maxrate #{job.profile.max_video_bitrate}k" if job.profile.max_video_bitrate
          cmd += " -minrate #{job.profile.min_video_bitrate}k" if job.profile.min_video_bitrate
        end

        # bitrate
        if job.profile.video_bitrate.to_f > 0.0
          cmd += " -b #{job.profile.video_bitrate}k -bt #{job.profile.bitrate_tolerance || job.profile.video_bitrate}k "
        else
          optimum = optimal_bitrate(dim_info, job)
          cmd += " -b #{optimum}k -bt #{job.profile.bitrate_tolerance || optimum}k"
        end

        if job.profile.add_padding?
          cmd += padding_command(dim_info) 
        end

        cmd += " #{job.profile.extra_param}" # can use S3 link directly here? if the file is public
        temp_file_path = "#{Time.now.to_i}#{job.generate_convert_filename}"
        if job.watermark_image
          cmd = "#{FFMPEG_WITH_VHOOK_PATH} -i #{job.original_file.file_path} #{cmd} #{watermark_command(job)} #{File.join(FILE_FOLDER, temp_file_path)} 2>&1"
        else
          cmd = "#{FFMPEG_PATH} -i #{job.original_file.file_path} #{cmd} #{File.join(FILE_FOLDER, temp_file_path)} 2>&1"
        end
        cmd += ";mv #{File.join(FILE_FOLDER, temp_file_path)} #{File.join(FILE_FOLDER, job.generate_convert_filename)}"
        Transcoder.logger.debug cmd
        cmd
      end

      private

      def self.trimming_command(profile,video)
        current_duration = video.duration.nil? ? 0 : (video.duration.to_i / 1000)

        # there is no more time, so give zero length video
        return " -ss #{current_duration > 0.5 ? current_duration - 0.5 : current_duration} -an -vframes 1" if (profile.trim_begin.to_i > current_duration)

        cmd = ""
        cmd += " -ss #{profile.trim_begin}" unless profile.trim_begin.to_i < 1
        cmd += " -t #{profile.trim_end}" unless profile.trim_end.to_i < 1

        cmd
      end

      def self.watermark_command(job)
        %Q[-vhook "#{VHOOK_WATERMARK_PATH} -m #{job.profile.watermark_mode} -t #{job.profile.watermark_effective_bgcolor} -f #{job.watermark_image}"]
      end

      def self.video_command(dim_info, job)
        unless job.profile.video_codec.blank?
          cmd = ""
          cmd += " -vcodec #{job.profile.video_codec}"
          cmd += " -r #{job.profile.video_fps}" unless job.profile.video_fps.blank?
          cmd += size_command(dim_info, job)
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

      def self.x264_command(x264_options)
        cmd = ""
        (x264_options.blank? ? {} : JSON.parse(x264_options)).each do |option, values|
          values.each{|v| cmd += " -#{option} #{v}" }
        end
        cmd
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

      # changes mantissa (e.g. "123.(45678)"; see
      # http://wikipedia.org/wiki/Significand
      # ) to the number of one-thousandth
      def self.mantissa_to_milli mantissa
        (mantissa.to_i*10**(3-mantissa.length)).to_i
      end

      def self.parse_duration(line, profile)
        if line =~ /Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})/m
          total = (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 1000 + mantissa_to_milli($4)
          seek  = profile.trim_begin.to_i*1000
          duration = (profile.trim_end.to_i>0 ? profile.trim_end.to_i*1000 : total)
          [total-seek, duration-seek].min
        else
          nil
        end
      end

      def self.parse_progress(line,duration)
        if line =~ /time=\s*(\d+).(\d+)/  
          # the last condition occurs @ seeking
          if duration.nil? || duration == 0 || $1 == "10000000000"
            p = 0
          else
            p = ($1.to_i * 1000 + mantissa_to_milli($2)) * 100 / duration
          end
          p = 100 if p > 100
          p.to_i
        else 
          0
        end
      end

    end
  end
end
