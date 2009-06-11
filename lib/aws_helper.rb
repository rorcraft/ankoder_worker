module AwsHelper

  private
  
  def s3_connect
    unless AWS::S3::Base.connected?
    AWS::S3::Base.establish_connection!(
      :access_key_id => ACCESS_KEY_ID,
      :secret_access_key => SECRET_ACCESS_KEY,
      :server => S3_SERVER,
      :persistent => true
     )
    end
  end

end


