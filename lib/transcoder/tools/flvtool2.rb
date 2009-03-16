module Transcoder
  module Tools
    class Flvtool2

      include Transcoder
      class << self
        include Transcoder::Helper
      end
      
      FLVTOOL_PATH = "/opt/local/bin/flvtool2" unless defined? FLVTOOL_PATH
      
      def self.add_title(job)
        system add_title_command(job)
      end
      
      def self.add_title_command(job)
        "flvtool2 -U -title:'#{job.original_file.name}' #{job.generate_convert_filename}"
      end

    end
  end
end