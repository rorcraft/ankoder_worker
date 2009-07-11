class Job < ActiveResource::Base
  self.site = AR_SITE

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

=begin
  def finish(success=true)
    self.finished_at = Time.now
    success or user.unuse_one_token
    save
  end
=end

  # TODO: add job_id to filename otherwise multiple jobs with same suffix can overwrite each other
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

  def send_to_queue
    post(:send_to_queue)
  end

  def get_upload_url
    upload_url ? upload_url : user.upload_url
  end

end
