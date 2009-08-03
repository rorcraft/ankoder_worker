require 'flvtools'
module Flvtools
  module Tools
    class FlvtoolPlusPlus

      FLVTOOL_PLUS_PLUS_PATH = "/usr/local/bin/flvtool++" unless defined? FLVTOOL_PLUS_PLUS_PATH

      def self.command(path)
        convert_file = path
        tmp_file = "#{path}.tmp.flv"
        cmd = "#{FLVTOOL_PLUS_PLUS_PATH}" 
        cmd += " #{convert_file}"
        cmd += " #{tmp_file} "
        cmd += "&& mv #{tmp_file} #{convert_file}"

        cmd
      end

      def self.get_duration(path)
        result = ""
        command = get_metadata_command path
        io = IO.popen(command) do |pipe|
          pipe.each("\n") do |line|
            if line =~ /duration:\s(.*)$/
              result = $1
            end
          end
        end
        result.to_f
      rescue
        0
      end

      def self.get_metadata_command(path)
        cmd = "#{FLVTOOL_PLUS_PLUS_PATH} #{path}"
      end

      def self.add_title_command(title, path)
        tmp_file = "#{path}.tmp.flv"
        cmd = "#{FLVTOOL_PLUS_PLUS_PATH} -tag title '#{title}' #{path} #{tmp_file}"
        cmd += " && mv #{tmp_file} #{path}"
      end

    end
  end
end
