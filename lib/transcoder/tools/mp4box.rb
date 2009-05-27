
module Transcoder
  module Tools
    class Mp4box
      include Transcoder
      
      class << self 
        include Transcoder::Helper
      end
    
      def self.run(path)
        run_command command(path)
      end
      
      def self.run_command(command)
        io = IO.popen(command) 
        io.close
      raise TranscoderError::MP4BoxHintingException if $?.exitstatus != 0
        
      end
    
      def self.command(path)
        cmd = "MP4Box -hint #{path}"
      end
    
    end
  end  
end
