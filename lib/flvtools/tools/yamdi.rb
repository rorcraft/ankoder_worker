require 'flvtools'
module Flvtools
  module Tools
    class Yamdi

      YAMDI_PATH = "/usr/local/bin/yamdi" unless defined? YAMDI_PATH

      def self.add_hint_command(path)
        convert_file = path
        tmp_file = "#{path}.tmp.flv"
        cmd = "#{YAMDI_PATH}"
        cmd += " -i #{convert_file}"
        cmd += " -o #{tmp_file} "
        cmd += "&& mv #{tmp_file} #{convert_file}"
      end

      def self.add_title(job)
        system add_title_command(job)
      end

    end
  end
end
