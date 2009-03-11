module Transcoder
  module Helper
    private
    
    def progress_need_refresh?(current_progress, new_progress)
      current_progress.nil? || (new_progress - current_progress) >= 10 || new_progress == 100
    end

    def stdout_progress(progress)
      puts "progress: #{progress}"
    end
    
   
          
  end
end