class Postback

  CURL_FLAGS =
    %Q[ \\
      -v -L -Y 100 \\
      --connect-timeout #{TimeoutDetector::DETECTOR_TIMEOUT_SEC} \\
      -y #{TimeoutDetector::DETECTOR_TIMEOUT_SEC} \\
    ]

  def self.logger
    @@logger = RAILS_DEFAULT_LOGGER if !defined?(@@logger) &&
      (defined?(RAILS_DEFAULT_LOGGER) && !RAILS_DEFAULT_LOGGER.nil?)
    @@logger = ActiveRecord::Base.logger unless defined?(@@logger)
    @@logger = Logger.new(STDOUT) unless defined?(@@logger)
    @@logger
  end

  def self.post_back(type, model, result, error='')
    return if (!model.respond_to?('profile') || model.profile.blank? || model.profile.postback_url.blank?) && (!model.respond_to?('user') || model.user.blank? || model.user.postback_url.blank?)
    case type
    when 'download'
      # model = Video's instance
      message = {
        "result" => result,
        "error" => error,
        "type" => "Download",
        "video_id"=> model.id,
        "video_name" => model.filename
    }

    when 'convert'
      # model = instance of Job
      message = {
        'result'  =>  result,
        'error'   =>  error,
        'type'    => 'Convert',
        'Job'     =>  model.id,
        'original_video_id' => model.original_file.id,
        'is_trimmed' => {true => true, nil => false, false => false}[((model.profile.trim_begin || model.profile.trim_end) && (model.convert_file.duration == model.original_file.duration))],
      }
      if result   == 'success'
        message['convert_video_id'] = model.convert_file.id
        message['s3_name'] = model.convert_file.s3_name
        message['name'] = "#{model.convert_file.id}_#{model.convert_file.filename}"
        tus = (model.thumbnails.map &:uploaded rescue [])
        message['thumbnail_result'] = 
          case [tus.inject{|i,j|i&&j}, tus.inject{|i,j|i||j}]
          when [true, true ] then 'success'
          when [false,false] then 'fail'
          when [nil,  nil  ] then ''
          else 'partial_success'
          end
      end

    when 'test'
      message = {
        'result'  =>  'sucess',
        'type'    => 'Test',
    }

    when 'upload'
      # model = instance of Job
      message = {
        #'Job'     => model.id,
        'job'     => upload_message(model),
        'result'  => result,
        'error'   => error,
        'type'    => 'Upload',
        #'Video'   => video,
        #'Origin'  => model.original_file.attributes,
        #'url'     => model.get_upload_url,
        #"thumbnail_filenames" => model.convert_file.thumbnails.map(&:filename)
    }
    end

    message = message.to_json
    private_key = model.user.private_key

    encoded_message = Base64.encode64(HMAC::SHA1::digest(private_key, message)).strip

    postback_url = (model.respond_to?('profile') && !model.profile.blank? && model.profile.postback_url) ? model.profile.postback_url : model.user.postback_url

    curl_cmd = "curl #{CURL_FLAGS} -H \"Content-type: application/x-www-form-urlencoded\" #{postback_url} -d \"message=#{CGI.escape(message)}&signature=#{CGI.escape(encoded_message)}\""
    logger.info curl_cmd
    f = IO.popen(curl_cmd +" 2>&1")
    result = f.read
    f.close
  rescue Exception => e
    logger.debug result
    logger.error e.to_yaml
    logger.error e.backtrace.to_yaml
  ensure
    return result
  end

  # Construct postback message for upload phase
  # Input: instance of Job
  # Output: job with original_file and convert file details
  def self.upload_message(job)
    input = job.original_file
    output = job.convert_file
    convert_file = {"name" => output.name, "duration" => output.duration, "size" => output.size, "id" => output.id, "filename" => output.s3_name, "url" => "#{job.get_upload_url}/#{output.s3_name}", "height" => output.height, "width" => output.width, "thumbnails" => output.thumbnails.map(&:filename) }
    original_file = {"name" => input.name, "duration" => input.duration, "size" => input.size, "id" => input.id, "height" => input.height, "width" => input.width}
    job_hash = {"id" => job.id, "profile" => {"name" => job.profile.name, "id" => job.profile.id }, "status" => job.status, "input_file" => original_file, "output_file" => convert_file}
    job_hash
  end
end
