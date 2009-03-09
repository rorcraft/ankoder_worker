class Video < ActiveResource::Base
  self.site = AR_SITE

  def file_path(filename = nil)
    filename = filename || self.filename
    File.join(FILE_FOLDER,filename) unless filename.nil?
  end
  
  def s3_url(option = {})
    s3_connect
    AWS::S3::S3Object.url_for(self.s3_name, S3_BUCKET, option)    
  end
  
  def s3_exist?
    s3_connect
    AWS::S3::S3Object.exists?(self.s3_name, S3_BUCKET) 
  end
  
  def s3_name
    "#{self.id}_#{self.filename}"
  end

end
