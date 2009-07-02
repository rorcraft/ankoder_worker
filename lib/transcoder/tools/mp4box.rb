
module Transcoder
  module Tools
    class Mp4box
      MP4BOX_PATH = "MP4Box" unless defined? MP4BOX_PATH
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
        cmd = "#{MP4BOX_PATH} -out #{tmp_file} -hint #{path} 2>&1;"
        cmd += " mv #{tmp_file} #{path}"
      end
    
    end
  end  
end
