require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/s3")

describe Transcoder::Tools::S3 do
  remote_fixtures
    
  
  it "should get curl command" do
    destination_filename = "testfile.mp4"
    curl_command = "#{Transcoder::Tools::S3::S3CURL} #{Transcoder::Tools::S3::access_param} --put=#{test_file} -- http://s3.amazonaws.com/#{TEST_BUCKET}/#{destination_filename}"
    cmd = Transcoder::Tools::S3.get_curl_command(curl_command)
    puts cmd
  end
  
  it "should upload to default bucket" do
    destination_filename = "testfile.mp4"
    original_filename = "kites.mp4"
    Transcoder::Tools::S3.upload(destination_filename, test_file)    
  end
  
  
  it "should export to client's bucket (granted access by email)" do
    rex_s3bucket = "rex-ankodertest"
    destination_filename = "testfile.mp4"
    original_filename = "kites.mp4"
    Transcoder::Tools::S3.upload(destination_filename, test_file, {"bucket" => rex_s3bucket, "original_filename" => original_filename })    
  end
 

  it "should throw no such bucket error " do
    destination_filename = "testfile.mp4"
    original_filename = "kites.mp4"
    lambda do
      Transcoder::Tools::S3.upload(destination_filename, test_file, {"bucket" => "rex-ankoderte232st", "original_filename" => original_filename })        
    end.should raise_error Transcoder::Tools::S3::S3NoSuchBucket
  end

  it "should throw Access Denied error " do
    destination_filename = "testfile.mp4"
    original_filename = "kites.mp4"
    lambda do
      Transcoder::Tools::S3.upload(destination_filename, test_file, {"bucket" => "rex-temp", "original_filename" => original_filename })        
    end.should raise_error Transcoder::Tools::S3::S3AccessDenied
  end
  
  it "should download from default bucket" do
    destination_filename = "testfile.mp4"
    Transcoder::Tools::S3.download(destination_filename, local_file)        
  end
  
  it "should download from client's bucket" do
    destination_filename = "testfile.mp4"
    rex_s3bucket = "rex-ankodertest"
    Transcoder::Tools::S3.download(destination_filename, local_file("kites_from_client_S3.mp4"), :bucket => rex_s3bucket)        
  end
  
  it "should handle unknown file download" do
    Transcoder::Tools::S3.download("no_such_file", local_file("kites_from_client_S3.mp4"))        
    # <?xml version="1.0" encoding="UTF-8"?>
    # <Error><Code>NoSuchKey</Code><Message>The specified key does not exist.</Message><Key>no_such_file</Key><RequestId>2CE0BAD55E045BF7</RequestId><HostId>9J2gvgGU/BIka/rtPNyR+oFVJi1jM6ByNP/7PRn6bCIPLCRJonYmbKD6B+pQfrsk</HostId></Error>    
  end
  
  it "should get head information " do
    destination_filename = "testfile.mp4"    
    Transcoder::Tools::S3.head(destination_filename)
    
  end
  
  
  it "should delete file from s3" do
    destination_filename = "testfile.mp4"    
    p Transcoder::Tools::S3.delete(destination_filename)    
  end
  
  it "should delete from client's bucket" do
    destination_filename = "testfile.mp4"    
    p Transcoder::Tools::S3.delete(destination_filename, :bucket => "rex-ankodertest")        
  end
end

  def test_file 
    File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites.mp4")
  end
  
  def local_file(filename = nil)
    filename ||= "kites_formS3.mp4" 
    File.expand_path("#{RAILS_ROOT}/file_system/#{filename}")
  end
