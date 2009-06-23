
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
        io = IO.popen(command + " 2>&1") 
        error = io.read
        io.close
      raise TranscoderError::MP4BoxHintingException.new(error) if $?.exitstatus != 0
        
      end
    
      def self.command(path)
        tmp_file = "#{path}.tmp"
        cmd = "MP4Box -out #{tmp_file} -hint #{path} 2>&1;"
        cmd += " mv #{tmp_file} #{path}"
      end
    
    end
  end  
end
