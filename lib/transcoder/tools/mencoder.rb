
module Transcoder
  module Tools
    class Mencoder

      include Transcoder
      class << self
      include Transcoder::Padding
      include Transcoder::Helper
      end
      
      MENCODER_PATH = "/opt/local/bin/mencoder" unless defined? MENCODER_PATH
      

      # preprocess - what for? get higher quality?
      def self.preprocess_command(job)
        cmd = "#{MENCODER_PATH} -vf lavcdeint,hqdn3d #{job.original_file.file_path} -o #{job.original_file.file_path}.preprocess -oac pcm -ovc lavc -lavcopts " 
        cmd += "vcodec=ffvhuff:vstrict=-1:vhq:psnr -of avi"
        cmd += " && mv #{job.original_file.file_path}.preprocess #{job.original_file.file_path}"
        cmd
      end
      
      def self.preprocess(job)
        IO.popen(preprocess_command(job)) do |pipe|
          pipe.read
        end
      end

    end
  end
end
