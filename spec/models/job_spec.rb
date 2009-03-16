require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Job do
  
  remote_fixtures
  
  
  it "should find Job" do
    jobs(:kites_to_flv).should_not be_nil    
  end
  
  it "should find original_file" do
    jobs(:kites_to_flv).original_file.should == videos(:kites)
  end
  
  it "should find profile" do
    jobs(:kites_to_flv).profile.should == profiles(:flv)
  end
  
  it "should generate a convert_file filename" do
    jobs(:kites_to_flv).generate_convert_filename.should == "#{videos(:kites).filename.split('.')[0]}.flv"
  end
  
end
