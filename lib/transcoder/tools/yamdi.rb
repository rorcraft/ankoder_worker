
module Transcoder
  module Tools
    class Yamdi
      include Transcoder
      YAMDI_PATH = "/usr/local/bin/yamdi" unless defined? YAMDI_PATH      
      
      class << self 
        include Transcoder::Helper
      end
    
      def self.run(path)
        run_command command(path)
      end
      
      def self.run_command(command)
        io = IO.popen(command) 
        io.close
      raise TranscoderError::MetaInjectionException if $?.exitstatus != 0
        
     # rescue TranscoderError => e
     #   Transcoder.logger.error e.message
     #   Transcoder.logger.error e.backtrace.join("\n")
      end
    
      def self.command(path)
        convert_file = path
        tmp_file = "#{path}.tmp"
        cmd = "mv #{convert_file} #{tmp_file} "
        cmd += ";#{YAMDI_PATH} " 
        cmd += " -i #{tmp_file} "
        cmd += " -o #{convert_file}"
        cmd += ";rm #{tmp_file}"
      end
    
    end
  end  
end
