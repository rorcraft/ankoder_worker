require 'json'
require 'rorcraft_helper'

module Transcoder
  
  class TranscoderError < RuntimeError
    class MetaInjectionException < TranscoderError
    end

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
      job.set_status("processing") # (update started_at = time.now)

      if S3_ON
        Transcoder.logger.debug "download from S3"
        S3Curl.download(job.original_file.s3_name,job.original_file.file_path) 
      end
      # download watermark
      
      # if HD Flash 
        # Mkmp4.run(job) why do we need this? MP4Box
      # if Theora
        # FFmpeg2Theora.run(job)
      # else Transcode the video
      Tools::FFmpeg.run(job)
          
      Transcoder.logger.debug "create the converted file"
      convert_file = create_convert_file(job)
      
      # if flv - add title
      # Flvtool2.add_title(job)
      
      # if MP4 for Flash
      # QtFaststart.run(job)

      Transcoder.logger.debug "generate thumbnail for converted file"
      convert_file.generate_thumbnails
      
      if S3_ON
        Transcoder.logger.debug "upload thumbnail to S3"
        convert_file.upload_thumbnails_to_s3      
        Transcoder.logger.debug "upload converted file back to S3"
        convert_file.upload_to_s3
      end
      
      # FTP the file. 
      # send to ftp queue and ftp worker to ftp? from another machine
      # FTP the thumbnail as well      
      
      # Upload to Client's S3 ?
      
      # Post back to client's server

      # remove local watermark
      # remove local thumbnail
      # remove local original file
      # remove local convert file
      
      job.set_status("complete")
      
    rescue TranscoderError
      job.set_status("failed")
      
    end
    
    def create_convert_file(job)
      converted_video = ConvertFile.new
      converted_video.filename          = job.generate_convert_filename
      converted_video.original_filename = job.generate_convert_file_original_filename
      converted_video.size              = File.size(job.convert_file_full_path)  
      converted_video.user_id           = job.user_id
      # converted_video.video_codec       = 
      converted_video.read_metadata
      converted_video.save
      Transcoder.logger.debug converted_video.inspect     
      job.convert_file_id = converted_video.id
      job.save
      
      return converted_video
    end
    
  end
  
  
end    
