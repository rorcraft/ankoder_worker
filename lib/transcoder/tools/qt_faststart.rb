# All that qt-faststart does is take an Apple QuickTime file that looks like this:
# 
#   [ 'mdat' QT data atom ]    [ 'moov' QT info atom ]
# 
# and rearranges it to look like this:
# 
#   [ 'moov' QT info atom ]    [ 'mdat' QT data atom ]
# 
# http://multimedia.cx/eggs/improving-qt-faststart/
module Transcoder
  module Tools
    class QtFaststart

      include Transcoder
      class << self
      include Transcoder::Helper
      end
      
      QTFASTSTART_PATH = "#{RAILS_ROOT}/lib/transcoder/bin/qt-faststart" unless defined? QTFASTSTART_PATH
      

      # preprocess - what for? get higher quality?
      def self.run(job)
          Transcoder.logger.debug "QtFaststart: job:#{job.id} original_file:#{job.original_file.id}"
          system command(job)
          if job.convert_file.file_exist?
            `rm #{job.convert_file.filename}.orig`
          else
            `mv #{job.convert_file.filename}.orig #{job.convert_file.filename}`
          end
      end
      
      def self.command(job)
          "mv #{job.convert_file.filename} #{job.convert_file.filename}.orig && qt-faststart #{job.convert_file.filename}.orig #{job.convert_file.filename}"        
      end

    end
  end
end