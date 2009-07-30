require 'flvtools'
module Flvtools
  module Tools
    class Flvtool2 # this may be very slow for large files

      FLVTOOL2_PATH = "/usr/local/bin/flvtool2" unless defined? FLVTOOL2_PATH

      def self.add_title(job)
        system add_title_command(job)
      end

      def self.add_title_command(title, path)
        cmd = "#{FLVTOOL2_PATH} -U -title:'#{title}' #{path}"
      end

    end
  end
end
