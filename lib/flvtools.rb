require 'flvtools/tools/flvtool2'
require 'flvtools/tools/flvtool_plus_plus'
require 'flvtools/tools/yamdi'
module Flvtools
  class FlvtoolError < RuntimeError
    class MetaInjectionException < FlvtoolError
    end
  end
  class Flvtool
    def self.hint(path)
      run_command add_hint_command(path)
    end

    def self.run_command(command)
      io = IO.popen(command) do |pipe|
        pipe.read
      end
      raise FlvtoolError::MetaInjectionException if $?.exitstatus != 0
    end

    def self.add_hint_command(path)
      #duration = Flvtools::Tools::FlvtoolPlusPlus.get_duration(path)
      #if duration > 16777990
      #  tool = Flvtools::Tools::FlvtoolPlusPlus
      #else
      tool = Flvtools::Tools::Yamdi
      #end
      tool.add_hint_command(path)
    end

    def self.add_title(*opts)
      tool = Flvtools::Tools::FlvtoolPlusPlus
      run_command tool.add_title_command(*opts)
    end

  end
end
