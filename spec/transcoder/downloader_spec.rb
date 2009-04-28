require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/downloader")

describe Downloader do
  remote_fixtures
    
  it "should return download command" do
    cmd = Downloader.command("http://s3.amazonaws.com/testVideo/29mb.mov", "29mb.mov")
    puts cmd
    cmd.should_not be_nil
  end

  it "should download (uncomment this)"
  
  # it "should download " do        
  #   filename = "29mb.mov"
  #   assert Downloader.download("http://s3.amazonaws.com/testVideo/29mb.mov", filename)
  #   
  #   file_path = File.join(Downloader::TEMP_FOLDER, filename)
  #   assert File.exists?(file_path)
  #   File.rm(file_path)
  # end
  
  it "should download from Youtube (uncomment this)"
  
  it "should download from Metacafe (uncomment this)"

  it "should download from FTP (uncomment this)"
        
  it "should download from secure FTP"
  
  it "should download from secure HTTP (basic auth)"
  
  it "should download from secure S3 (test with bucket granted with read permission)"
          
end