module Transcoder

  class Segmenter
    def self.segment(job, video_id)
      `#{command(job, video_id)}`
      raise TranscoderError::SegmenterFault unless $?.exitstatus == 0
    end

    def self.command(job, video_id)
      cmd = %Q[cd #{FILE_FOLDER} && #{SEGMENTER_PATH} "#{job.convert_file_full_path}" "#{job.profile.segment_duration}" "#{video_id}_#{job.segment_prefix}" "#{job.segment_index}" "#{job.user.url_prefix}"]
      Transcoder.logger.debug cmd
      cmd
    end

  end

end
