class DownloaderProcessor < ApplicationProcessor

  subscribes_to :downloader_worker

  def on_message(message)
    logger.debug "DownloaderProcessor received #{message.class}: " + message
    video  = get_video(message)
    local_filename = video.make_hashed_name
    while File.exist?(Downloader.temp_path(local_filename))
      local_filename = video.make_hashed_name
    end
    temp_filepath  = Downloader.download(
      :url => video.source_url, :local_filename => local_filename) do |progress|
         video.progress = progress
	 video.save
    end
    
    # avoid collision
    loop do
      video.filename = video.make_hashed_name
      break unless File.exist?(video.file_path)
    end
    # move file from tmp folder to usual file_path 
    FileUtils.mv temp_filepath , video.file_path if temp_filepath
    
    ### return , log error if temp_filepath is false   
    video.progress = 100 
    video.read_metadata
    video.extract_file_information
    logger.debug "Thumbnail generation: #{video.generate_thumbnails}"
    video.save
    
    if S3_ON
      Downloader.logger.debug "upload thumbnail to S3"
      video.upload_thumbnails_to_s3      
      Downloader.logger.debug "upload converted file back to S3"
      video.upload_to_s3
    end
    
    # postback? - file downloaded
    video.upload_post_back(video,'success')
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
