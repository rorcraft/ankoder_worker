
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
        _command = command + " 2>&1"
        Transcoder.logger.debug _command
        io = IO.popen(_command) 
        error = io.read
        io.close
      raise TranscoderError::MP4BoxHintingException.new(error) if $?.exitstatus != 0
        
      end
    
      def self.command(path)
        tmp_file = "#{path}.tmp"
        cmd = "#{MP4B0X_PATH} -out #{tmp_file} -hint #{path} 2>&1;"
        cmd += " mv #{tmp_file} #{path}"
      end
    
    end
  end  
end
