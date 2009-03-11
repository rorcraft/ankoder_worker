class Job < ActiveResource::Base
  self.site = AR_SITE
  
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

  def generate_convert_filename
    if convert_file.nil?
      "#{original_file.filename.split(".")[0]}.#{profile.suffix}" 
    else
      convert_file.filename
    end
  end
  
end
