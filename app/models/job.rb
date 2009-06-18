class Job < ActiveResource::Base
  self.site = AR_SITE
  
  STATUS = %w{ submitting queuing processing complete }
  
  def profile
    @profile ||= Profile.find(profile_id) if profile_id
    @profile
  rescue
    nil
  end
  
  def original_file
    @original_file ||= Video.find(original_file_id) if original_file_id
    @original_file
  rescue
    nil
  end
  
  def convert_file
    @convert_file ||= Video.find(convert_file_id) if convert_file_id
    @convert_file
  rescue
    nil
  end
  
  def user
    @user ||= User.find(user_id) if user_id
    @user
  rescue
    nil
  end

  def finish(success=true)
    self.finished_at = Time.now
    success or user.unuse_one_token
    save
  end

  # TODO: add job_id to filename otherwise multiple jobs with same suffix can overwrite each other
  def generate_convert_filename
    if convert_file.nil? or convert_file.filename.nil?
      "#{original_file.filename.split(".")[0]}.#{profile.suffix}" 
    else
      convert_file.filename
    end
  end

  def generate_convert_file_original_filename
    if convert_file.nil? or convert_file.original_filename.nil?
      "#{original_file.original_filename.split(".")[0]}.#{profile.suffix}"
    else
      convert_file.original_filename
    end  
  end

  def convert_file_full_path
    File.join(FILE_FOLDER, generate_convert_filename)
  end
  
  def set_status(_status)
    put(:set_status, :status => _status)
    self.status = _status
  end

  def get_upload_url
    upload_url ? upload_url : user.upload_url
  end

  def get_thumbnail_sizes
    @thumbnail_sizes ||= JSON.parse thumbnail_sizes
  end

end
