require 'rubygems'
require 'active_support'
require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + "/../lib/s3curl"

describe S3Curl do    
  
  it "should get curl command" do
    destination_filename = "testfile.mp4"
    curl_command = "#{S3CURL} #{S3Curl::access_param} --put=#{test_file} -- http://s3.amazonaws.com/#{TEST_BUCKET}/#{destination_filename}"
    cmd = S3Curl.get_curl_command(curl_command)
    puts cmd
  end
  
  it "should upload to default bucket" do
    S3Curl.upload(destination_filename, test_file)    
  end
  
  
  it "should export to client's bucket (granted access by email)" do
    rex_s3bucket = "rex-ankodertest"
    S3Curl.upload(destination_filename, test_file, {"bucket" => rex_s3bucket, "original_filename" => original_filename })    
  end
 

  it "should throw no such bucket error " do
    lambda do
      S3Curl.upload(destination_filename, test_file, {"bucket" => "rex-ankoderte232st", "original_filename" => original_filename })        
    end.should raise_error S3Curl::S3NoSuchBucket
  end

  it "should throw Access Denied error " do

    lambda do
      S3Curl.upload(destination_filename, test_file, {"bucket" => "rex-temp", "original_filename" => original_filename })        
    end.should raise_error S3Curl::S3AccessDenied
  end
  
  it "should download from default bucket" do
    S3Curl.download(destination_filename, local_file)        
  end
  
  it "should download from client's bucket" do
    rex_s3bucket = "rex-ankodertest"
    S3Curl.download(destination_filename, local_file("kites_from_client_S3.mp4"), :bucket => rex_s3bucket)        
  end
  
  it "should handle unknown file download" do
    S3Curl.download("no_such_file", local_file("kites_from_client_S3.mp4"))        
    # <?xml version="1.0" encoding="UTF-8"?>
    # <Error><Code>NoSuchKey</Code><Message>The specified key does not exist.</Message><Key>no_such_file</Key><RequestId>2CE0BAD55E045BF7</RequestId><HostId>9J2gvgGU/BIka/rtPNyR+oFVJi1jM6ByNP/7PRn6bCIPLCRJonYmbKD6B+pQfrsk</HostId></Error>    
  end
  
  it "should get head information " do
    S3Curl.head(destination_filename)    
  end
  
  
  it "should delete file from s3" do
    p S3Curl.delete(destination_filename)    
  end
  
  it "should delete from client's bucket" do
    p S3Curl.delete(destination_filename, :bucket => "rex-ankodertest")        
  end
end

  def destination_filename
    "remote_test_file.txt"
  end
  
  def original_filename
    "test_file.txt"
  end
  
  def test_file 
    File.expand_path(File.dirname(__FILE__) + "/../fixtures/test_file.txt")
  end
  
  def local_file(filename = nil)
    filename ||= "test_download.txt" 
    File.expand_path("#{RAILS_ROOT}/fixtures/#{filename}")
  end
