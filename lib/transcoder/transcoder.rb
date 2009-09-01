require 'json'
require 'rorcraft_helper'

module Transcoder
  
  class TranscoderError < RuntimeError
    class MP4BoxHintingException < TranscoderError
    end

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
    
    class UnknownEncoder < TranscoderError; end

    class SegmenterFault < TranscoderError; end

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
      
      case job.original_file.video_codec
      when /iv.0/i # iv30 iv40 iv50
        Tools::Mencoder.preprocess(job)        
      end
      Watermark.generate(job) if job.watermark_image
      
      case job.profile.video_codec
      when /theora/i
        Tools::FFmpeg.preprocess(job) if job.preprocess?
        Tools::FFmpeg2theora.run(job)
      else
        Tools::FFmpeg.run(job)
      end
          
      Transcoder.logger.debug "create the converted file"
      convert_file = create_convert_file(job)
      
      
      # if MP4 for Flash
      if convert_file.video_codec == "h264" && job.profile.video_format == "mp4"
        Transcoder.logger.debug "hinting the converted filei (mp4)"
        Tools::Mp4box.run(job.convert_file_full_path)  
      end

      # if FLV for flash
      if job.profile.video_format == "flv"
        require 'flvtools'
        Transcoder.logger.debug "hinting the converted file (flv)"
        Flvtools::Flvtool.hint(job.convert_file_full_path)
        Flvtools::Flvtool.add_title(job.original_file.name, job.convert_file_full_path)
      end
      
      Transcoder.logger.debug "generate thumbnail for converted file"
      job.generate_thumbnails

      if S3_ON
        Transcoder.logger.debug "upload converted file back to S3"
        convert_file.upload_to_s3
      end
      
      job.set_status Job::COMPLETED
      
    end
    
    def create_convert_file(job)
      converted_video = nil
      if job.profile.segment_duration
        v                       = ConvertFile.new
        v.s3_upload_trials      = 0
        v.filename              = job.theoretic_convert_filename
        v.original_filename     = job.generate_convert_file_original_filename
        v.size                  = File.size(job.convert_file_full_path)
        v.user_id               = job.user_id
        v.content_type          = job.profile.content_type if job.profile.respond_to?("content_type")
        v.read_metadata         :auto_file_extension => false
        v.filename              = job.segment_index
        v.save
        converted_video = v
        Segmenter.segment(job, v.id)
        v.segments              = Dir.glob(File.join(FILE_FOLDER, "*_" + job.segment_prefix + "-*.ts")).map{|path|path[File.dirname(path).length+1, path.length]}.to_json
        v.save
      else # no segmentation case
        converted_video = ConvertFile.new
        converted_video.s3_upload_trials  = 0
        converted_video.filename          = job.generate_convert_filename
        converted_video.original_filename = job.generate_convert_file_original_filename
        converted_video.size              = File.size(job.convert_file_full_path)
        converted_video.user_id           = job.user_id
        converted_video.content_type      = job.profile.content_type if job.profile.respond_to?("content_type")
        converted_video.read_metadata
        converted_video.save
      end
      Transcoder.logger.debug converted_video.inspect     
      job.convert_file_id = converted_video.id
      job.convert_file = converted_video
      job.newly_converted = converted_video
      job.save
      return converted_video
    end
    
  end
  
  
end    
