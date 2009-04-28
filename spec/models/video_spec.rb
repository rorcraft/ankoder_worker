require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Video do
  
  remote_fixtures
  
  
  it "should find video" do
    videos(:kites).should_not be_nil    
  end
  
  it "should check if filename_has_container?" do
    assert !videos(:downloaded).filename_has_container?
  end
  
  it "should return file_path" do
    v = videos(:kites)
    assert File.exists?(v.file_path)
  end
  
  it "read_metadata"do
    v = videos(:kites)
    v.read_metadata
    v.fps.to_s.should == "10"
  end

  it "read_metadata should save suffix"do
    v = videos(:kites)
    file_path = v.file_path
    v.filename = "kitessss"
    FileUtils.cp file_path, v.file_path
    old_file_path = v.file_path

    v.read_metadata
    v.filename.should == "kitessss.mov"
    
    assert !File.exists?(old_file_path)
    assert File.exists? v.file_path

    FileUtils.rm v.file_path
  end

  
  it "should extract original_filename from source url" do
    v = videos(:kites)
    v.source_url = "http://download.ankoder.com/remote_kites.mp4"
    v.extract_filename_from_url
    v.original_filename.should == "remote_kites.mp4"
  end
  
  it "should make hashed_name based on time" do
    v = videos(:kites)
    one = v.make_hashed_name
    sleep(1)
    two = v.make_hashed_name
    one.should_not eql two
  end
  
end