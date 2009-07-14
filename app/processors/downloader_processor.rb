class DownloaderProcessor < ApplicationProcessor

  subscribes_to :downloader_worker

  def on_message(message)
    temp_filepath = ''
    logger.debug "DownloaderProcessor received #{message.class}: " + message

    video  = get_video(message)
    begin
      local_filename = video.make_hashed_name
      while File.exist?(Downloader.temp_path(local_filename))
        local_filename = video.make_hashed_name
      end

      video.set_status Video::DOWNLOADING

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

      video.set_status Video::DOWNLOADED

      profile = find_custom_profile video.custom_profile unless video.custom_profile.nil?

      # create job and send it to queue.
      if profile # silently ignores invalid custom_profile
        job = Job.create :user_id => video.user.id, :original_file_id => video.id, :profile_id => profile.id
        job.send_to_queue
      end    

      # postback? - file downloaded
      Postback.post_back('download', video, 'success')

    rescue Exception => e
      File.delete(temp_filepath) if File.exist?(temp_filepath)

      video.set_status Video::FAILED
      
      error_message = case e
                      when HttpError
                        "HTTP status #{e.message}"
                      when BadVideoError
                        'The downloaded file is not a supported video'
                      when HostNotFoundError
                        'Download URL unreachable'
                      when AccessDeniedError
                        'Authentication failed'
                      when DownloadTimeoutError
                        'Download connection timed out'
                      when Downloader::DownloadError
                        e.message
                      else
                        logger.error e.to_yaml
                        logger.error e.backtrace.to_yaml
                        'Ankoder internal error'
                      end
      Postback.post_back('download', video,'fail',error_message)
    end
  end

  # message = {"type"=>"ASSIGN" , "content" => {"node_name" => "Downloader" , "config" => {"OriginalFile"=> self.id } }}.to_json
  def get_video message
    Video.find(get_video_id(message))
  end

  def get_video_id message
    msg = JSON.parse message

    # the former is proposed scaler message
    # the latter is legacy API message
    msg["video_id"] || msg["content"]["config"]["OriginalFile"]
  end

  def find_custom_profile(profile_id)
    Profile.find profile_id rescue nil                                               
  end

end
