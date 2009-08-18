class Job < ActiveResource::Base
  self.site = AR_SITE
  attr_accessor :newly_converted, :thumbnails

  SUBMITTING = "submitting"
  QUEUEING = "queuing"
  PROCESSING = "processing"
  COMPLETED = "completed"
  FAILED = "failed"
  
  STATUS = [SUBMITTING, QUEUEING, PROCESSING, COMPLETED, FAILED]

  EXCLUDE_WHEN_SAVING = [:profile, :convert_file, :original_file]
    

  def encode(options={})
    save_attributes = self.attributes.except(*EXCLUDE_WHEN_SAVING)
    case self.class.format
    when ActiveResource::Formats[:xml]
      self.class.format.encode(
        save_attributes,
        {:root => self.class.element_name}.merge(options))
    else
      self.class.format.encode(save_attributes, options)
    end
  end
    
  def user
    @user ||= User.find(user_id) if user_id
    @user
  rescue
    nil
  end

  def generate_convert_filename
    if !respond_to?('convert_file') || convert_file.nil? || convert_file.filename.nil?
      "#{original_file.filename.split(".")[0]}_#{id}.#{profile.suffix}" 
    else
      convert_file.filename
    end
  end

  def generate_convert_file_original_filename
    if !respond_to?('convert_file') || convert_file.nil? || convert_file.name.nil?
      "#{original_file.name.split(".")[0]}.#{profile.suffix}"
    else
      convert_file.name
    end  
  end

  def convert_file_full_path
    File.join(FILE_FOLDER, generate_convert_filename)
  end
  
  def set_status(_status)
    put(:set_status, :status => _status)
    self.status = _status
    # conflicts with current architecture
    # self.finish if _status == COMPLETED
  end

  def set_error(error)
    self.error = error
    self.save
  end

  def send_to_queue
    post(:send_to_queue)
  end

  def get_upload_url
    upload_url || user.upload_url
  end

  def get_thumbnail_upload_url
    thumbnail_upload_url || user.thumbnail_upload_url
  end

  def add_trimming?
    !((profile.trim_begin.blank? || profile.trim_begin == "0") && (profile.trim_end.blank? || profile.trim_end.to_i == "0"))
  end

  def preprocess?
     add_trimming? || (profile.add_padding.blank? || profile.add_padding == "false") # false is "false"?
  end

  # generate thumbnails for converted file
  def generate_thumbnails
    self.thumbnails = []

    # generate from thumb_moments
    (JSON.parse(profile.thumb_moments) rescue []).each do |time|
      self.thumbnails << Thumbnail.generate(
        newly_converted,
        :width  => profile.thumbnail_width,
        :height => profile.thumbnail_height,
        :time   => time) if time <= newly_converted.duration_in_secs
    end

    # generate from thumb_way
    thumb_start  = profile.thumb_start.to_f  > 0.0 ? profile.thumb_start.to_f  : 0.0
    thumb_end    = profile.thumb_end  .to_f  > 0.0 ? profile.thumb_end  .to_f  : newly_converted.duration_in_secs
    thumb_amount = profile.thumb_amount.to_i > 0   ? profile.thumb_amount.to_i : 0

    thumb_start = newly_converted.duration_in_secs if thumb_start > newly_converted.duration_in_secs
    thumb_end   = newly_converted.duration_in_secs if thumb_end   > newly_converted.duration_in_secs

    thumb_amount.times do |i|
      time =
        case profile.thumb_way
        when Thumbnail::RAND
          thumb_start + rand*(thumb_end-thumb_start)
        else#Thumbnail::EVEN
          thumb_start + (i+1)*(thumb_end-thumb_start)/(thumb_amount+1)
        end
      self.thumbnails << Thumbnail.generate(
        newly_converted,
        :width  => profile.thumbnail_width,
        :height => profile.thumbnail_height,
        :time   => time)
    end if thumb_start <= thumb_end
  end

end
