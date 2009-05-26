
module Transcoder
  module Tools
    class Yamdi
      include Transcoder
      
      class << self 
        include Transcoder::Helper
      end
    
      def self.run(job)
        run_command command(job)
      end
      
      def self.run_command(command)
        IO.popen(command) 

      raise TranscoderError::MetaInjectionException if $?.exitstatus != 0
        
      rescue TranscoderError => e
        Transcoder.logger.error e.message
        Transcoder.logger.error e.backtrace.join("\n")
      end
    
      def self.command(job)
        convert_file = File.join(FILE_FOLDER, job.generate_convert_filename)
        tmp_file = File.join(FILE_FOLDER, "_#{job.generate_convert_filename}")
        cmd = "mv #{convert_file} #{tmp_file} "
        cmd += ";yamdi " 
        cmd += " -i #{tmp_file} "
        cmd += " -o #{convert_file}"
        cmd += ";rm #{tmp_file}"
      end
    
    end
  end  
end
