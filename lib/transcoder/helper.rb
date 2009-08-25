module Transcoder
  module Helper
    def optimal_bitrate(dim_info, job)
      width = dim_info["result_width"]
      height = dim_info["result_height"]
      fps = (job.profile.video_fps || job.original_file.fps || 24.0).to_f
      fps * width * height / 5000.0
    end

    private

    PROGRESS_UPDATE_INTERVAL = 10 unless defined?(PROGRESS_UPDATE_INTERVAL)
    
    def progress_need_refresh?(current_progress, new_progress)
      last_update = @last_update.to_f
      current_time = Time.now.to_f
      if current_progress != new_progress && current_time-last_update >= PROGRESS_UPDATE_INTERVAL
        @last_update = current_time
        return true
      else
        return false
      end
    end

    def stdout_progress(progress)
      puts "progress: #{progress}"
    end
    
  end
end
