require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Profile do
  
  remote_fixtures
  
  
  it "should find profile" do
    profiles(:flv).should_not be_nil    
  end
  
  
end