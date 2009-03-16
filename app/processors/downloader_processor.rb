class DownloaderProcessor < ApplicationProcessor

  subscribes_to :downloader

  def on_message(message)
    logger.debug "DownloaderProcessor received: " + message
  end
end