class DownloaderProcessor < ApplicationProcessor

  subscribes_to :downloader

  def on_message(message)
    logger.debug "DownloaderProcessor received: " + message
    video  = get_video(message)
    Downloader.download(video.source_url)
    
    # move file from tmp folder to usual file_path 
    # FileUtils.cp File.join(TEMP_FOLDER,tempfile) , @original_file.file_path(File.basename(hashed_name))
    # FileUtils.rm File.join(TEMP_FOLDER,tempfile) if File.exist?@original_file.file_path(File.basename(hashed_name))
 
    video.read_metadata
    video.generate_thumbnails
    video.save
    
    if S3_ON
      Downloader.logger.debug "upload thumbnail to S3"
      video.upload_thumbnails_to_s3      
      Downloader.logger.debug "upload converted file back to S3"
      video.upload_to_s3
    end
    
    # postback? - file downloaded
  end

  # message = {"type"=>"ASSIGN" , "content" => {"node_name" => "Downloader" , "config" => {"OriginalFile"=> self.id } }}.to_json
  def get_video message
    Video.find(get_video_id(message))
  end

  def get_video_id message
    msg = JSON.parse message
    msg["content"]["config"]["OriginalFile"]
  end
  
end