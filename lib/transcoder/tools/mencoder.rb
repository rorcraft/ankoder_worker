
module Transcoder
  module Tools
    module Mencoder

      include Transcoder
      include Transcoder::Padding
      include Transcoder::Helper
   
      MENCODER_PATH = "/opt/local/bin/mencoder" unless defined? MENCODER_PATH
      
      def run
        
      end
      
      def command
        
      end

      # preprocess - what for? get higher quality?
      def preprocess_command(job)
        cmd = "#{MENCODER_PATH} #{job.original_file.file_path} -o #{job.original_file.file_path}.preprocess -oac mp3lame -lameopts preset=64 -ovc xvid -xvidencopts bitrate=600 -of avi"
        # fix mencoder's multiple of x bug: width/height can't be odd
        width = even_size job.original_file.width 
        height = even_size job.original_file.height 
        cmd += " -vf crop=#{width}:#{height}:0:0" if width or height
        cmd
      end
      
      def preprocess(job)
        progress = 0        
        IO.popen(preprocess_command(job)) # do |pipe|
        #           pipe.each("\r") do |line|
        #             if line =~ /\(\s*(\d+)%\)/
        #               p = $1.to_i
        #               p = 100 if p > 100
        #             end
        #           end
        #         end
        
      end

    end
  end
end