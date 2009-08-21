module Transcoder
  module Helper
    def optimal_bitrate(dim_info, job)
      width = dim_info["result_width"]
      height = dim_info["result_height"]
      fps = (job.profile.video_fps || job.original_file.fps || 24.0).to_f
      fps * width * height / 5000.0
    end

    private
    
    def progress_need_refresh?(current_progress, new_progress)
      current_progress.nil? || (new_progress - current_progress) >= 10 || new_progress == 100
    end

    def stdout_progress(progress)
      puts "progress: #{progress}"
    end
    
  end
end
