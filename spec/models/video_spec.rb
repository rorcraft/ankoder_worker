require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Video do
  
  remote_fixtures
  
  
  it "should find video" do
    videos(:kites).should_not be_nil    
  end
  
  
end