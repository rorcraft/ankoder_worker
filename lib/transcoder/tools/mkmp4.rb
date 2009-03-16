

module Transcoder
  module Tools
    class Mkmp4

      include Transcoder
      include Transcoder::Tools
      
      class << self
        include Transcoder::Padding
        include Transcoder::Helper
      end
      
      def self.run(job) 
        file_path = job.original_file.file_path #e.g. file.avi
        file_name = File.basename file_path
        file_dir  = File.dirname file_path
        watermark = ""
      

        Transcoder.logger.debug "Start of MKMP4 process"
        fps = `midentify "$file_path" | grep FPS | cut -d = -f 2`.strip
        Transcoder.logger.debug "FFMPEG Single Pass"
      
        # watermark = download_watermark ? "-vhook '/home/ffmpeg/usr/local/lib/vhook/watermark.so -f #{File.join(FILE_FOLDER,@profile.watermark)}'" : ""

        # FIXME: Does 2-pass have to do it this way?
        # FIXME: Where is the support for custom bitrate , width, height etc here??
        FFmpeg.run_command %{ cd #{file_dir} && #{FFmpeg::FFMPEG_PATH} -y -i "#{file_path}" #{watermark} #{FFmpeg.padding_command(job.profile, job.original_file)} -an 
        -pass 1 -vcodec libx264 -b 384k -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -flags2 +mixed_refs -me umh -subq 5 -trellis 1
        -refs 3 -bf 3 -b_strategy 1 -coder 1 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 384k -rc_eq 'blurCplx^(1-qComp)'
        -qcomp 0.8 -qmin 10 -qmax 51 -qdiff 4 "#{file_path}.temp.mp4" }
        
        Transcoder.logger.debug "FFMPEG Second Pass"
        
        FFmpeg.run_command %{ cd #{file_dir} && #{FFmpeg::FFMPEG_PATH} -y -i "#{file_path}" #{watermark} #{FFmpeg.padding_command(job.profile, job.original_file)} 
        -an -pass 2 -vcodec libx264 -b 384k -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -flags2 +mixed_refs -me umh 
        -subq 5 -trellis 1 -refs 3 -bf 3 -b_strategy 1 -coder 1 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 
        -bt 384k -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.8 -qmin 10 -qmax 51 -qdiff 4 "#{file_path}_temp.mp4" }
      
        # myfile.avi -> myfile.avi_temp.mp4
                
        Transcoder.logger.debug "Rename from \"#{file_path}_temp.mp4\" to \"#{file_path}_temp.264\""
        File.rename("#{file_path}_temp.mp4", "#{file_path}_temp.264")        
        # myfile.avi_temp.mp4 -> myfile.avi_temp.264        
         
        Transcoder.logger.debug "Extract Audio from \"#{file_path}\""
        Ffmpeg.run_command("cd #{file_dir} && #{FFMPEG_PATH} -i \"#{file_path}\"  -ar 48000 -ac 2 \"#{file_path}_temp.wav\"")        
        # myfile.avi -> myfile.avi_temp.wav
      
        if ( platform == "Mac" ) 
          FFmpeg.run_command("cd #{file_dir} && enhAacPlusEnc \"#{file_path}_temp.wav\" \"#{file_path}_temp.aac\" $audiobitrate s")
          # myfile.avi_temp.wav -> myfile.avi_temp.aac
        else
          FFmpeg.run_command("cd #{file_dir} && neroAacEnc -br 48000 -he -if \"#{file_path}_temp.wav\" -of \"#{file_path}_temp.mp4\"")
          # myfile.avi_temp.wav -> myfile.avi_temp.mp4
        end

        
        Transcoder.logger.debug "* * * Generating final MP4 container... * * *"
        FFmpeg.run_command("cd #{file_dir} && MP4Box -add \"#{file_path}_temp.264#video:fps=#{fps}\" \"#{file_path}.m4v\"")
        # myfile.avi_temp.264 -> myfile.avi.m4v
        
        # Merge audio back into m4v
        if ( platform == "Mac" ) 
          FFmpeg.run_command("cd #{file_dir} && MP4Box -add \"#{file_path}_temp.aac\" \"#{file_path}.m4v\"")
        else
          FFmpeg.run_command("cd #{file_dir} && MP4Box -add \"#{file_path}_temp.mp4#audio\" \"#{file_path}.m4v\"")
        end
                
        FFmpeg.run_command("cd #{file_dir} && MP4Box -inter 500 -itags album=\"#{album}\":artist=\"#{author}\":comment=\"#{comment}\":created=\"#{created}\":name=\"#{name}\" -lang English \"#{file_path}.m4v\"")

        FFmpeg.run_command("rm -rf #{file_path}_temp*") #myfile.avi_temp.264 .wav .acc .mp4

        Transcoder.logger.debug "* * * mkmp4 script end * * * "
        return "#{file_path}.m4v" #myfile.avi.m4v
      end
            
      private
      
      def self.platform
        if @platform.nil?
           @platform = case `uname`.strip
                      when 'Darwin' then 'Mac'
                      else 'Linux' end
        end
        @platform
      end
      
      def self.album ; "Ankoder.com" end
      def self.author ; "Ankoder.com" end
      def self.comment ; "Professionally encoded by Ankoder.com" end
      def self.created ; Time.now.year end
      
    end
  end
end
