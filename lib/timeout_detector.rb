class TimeoutDetector

  DETECTOR_POLL_INTERVAL_SEC = 300 unless\
    defined? DETECTOR_POLL_INTERVAL_SEC
  DETECTOR_TIMEOUT_SEC = 600 unless\
    defined? DETECTOR_TIMEOUT_SEC
  SECONDS_IN_A_DAY = 86400 unless defined? SECONDS_IN_A_DAY

  @poller_thread

  def initialize local_file_path
    @poller_thread = Thread.new(
      Thread.current
    ) do |main_thread|
      file_size = 0
      last_update = DateTime.now
      loop do
        new_size = File.size?(local_file_path).to_i
        current_time = DateTime.now
        file_size_change = new_size - file_size
        if(file_size_change > 0)
          file_size,last_update = new_size, current_time
        end
        time_since_file_size_changed =
          (current_time - last_update)*SECONDS_IN_A_DAY
        if(time_since_file_size_changed  > DETECTOR_TIMEOUT_SEC)
          # we have timed-out.
          main_thread.raise DownloadTimeoutError.new(
            "Timeout: the file #{local_file_path} has stayed unmodified " +
            "for #{DETECTOR_TIMEOUT_SEC} seconds."
          )
        end
        sleep DETECTOR_POLL_INTERVAL_SEC
      end
    end
  end

  def exit
    @poller_thread.exit
  end
end
