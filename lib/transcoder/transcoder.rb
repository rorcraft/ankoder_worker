require 'json'
require 'rorcraft_helper'

module Transcoder
  
  class TranscoderError < RuntimeError
    class MediaFormatException < TranscoderError
    end
    
    class InvalidCommand < TranscoderError
    end
  
    class InvalidFile < TranscoderError
    end
    
    class InputFileNotFound < TranscoderError
    end
    
    class UnexpectedResult < TranscoderError
    end
    
    class ParameterError < TranscoderError
    end
    
    class UnknownError < TranscoderError
    end
    
    class UnknownEncoder < TranscoderError ;end

  end
  
  def Transcoder.logger
    @@logger = RAILS_DEFAULT_LOGGER if !defined?(@@logger) && (defined?(RAILS_DEFAULT_LOGGER) && !RAILS_DEFAULT_LOGGER.nil?)
    @@logger = ActiveRecord::Base.logger unless defined?(@@logger)
    @@logger = Logger.new(STDOUT) unless defined?(@@logger)
    @@logger
  end
  
  module InstanceMethods
    
    def transcode(job)
      # job.set_status(:processing) (update started_at = time.now)
      
      # download job.original_file from S3 if S3_ON
      
      # download watermark
      
      # if HD Flash 
        # Mkmp4.run(job) why do we need this? MP4Box
      # if Theora
        # FFmpeg2Theora.run(job)
      # else Transcode the video
      Tools::FFmpeg.run(job)
        
  
      # create the converted file
      
      # if flv - add title
      # Flvtool2.add_title(job)
      
      # if MP4 for Flash
      # QtFaststart.run(job)

      # generate thumbnail for converted file
      # upload thumbnail to S3
      
      # upload converted file back to S3 is S3_ON
    
      # FTP the file. 
      # send to ftp queue and ftp worker to ftp? from another machine
      # FTP the thumbnail as well
      
      
      # Upload to Client's S3 ?
      
      # Post back to client's server

      # remove local watermark
      # remove local thumbnail
      # remove local original file
      # remove local convert file
      
      # job.set_status(:complete)
      
    rescue TranscoderError
      # job.set_status(:failed)
      
    end
    
    
  end
  
  
end    