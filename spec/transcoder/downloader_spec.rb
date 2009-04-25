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
  
  it "should download " do        
    file_path = Downloader.download("http://s3.amazonaws.com/testVideo/29mb.mov")
    assert File.exists?(file_path)
  end
  
      
end