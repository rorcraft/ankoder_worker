require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/padding")

describe Transcoder::Padding do

  class TestPadding 
    include Transcoder::Padding    
  end
  
  before :each do
    @p = TestPadding.new
  end
  
  it "even_size should return round up if odd number" do
    @p.even_size(2).should == 2
    @p.even_size(3).should == 4
    @p.even_size(5).should == 6
  end
  
  it "split_padding should split a length into two with even lengths" do
    # Since 1 pixel should not be noticable, we can do this
    @p.split_padding(10).should == [6,6]
    @p.split_padding(8).should == [4,4]
    @p.split_padding(13).should == [8,8]    
  end
  
  describe ".padding(profile_width,profile_height,video_width,video_height)" do
    it "defaults to 320x240" do
      result = @p.padding(0,0,-1,-1)
      result["result_height"].should == 240 
      result["result_width"].should == 320      
    end
    
    it "if video_height < 0 or video_width < 0, padding should return profile dimensions" do    
      result = @p.padding(320,240,-1,-1)
      result["result_height"].should == 240
      result["result_width"].should == 320
    end
    
    it "if profile dimensions = 0x0 then defaults to video original dimensions" do    
      result = @p.padding(0,0,320,240)
      result["result_height"].should == 240
      result["result_width"].should == 320
    end

    it "if profile = 16:9, video = 4:3 it'll pad width" do    
      result = @p.padding(1600,900,400,300)
      result["result_height"].should == 900
      result["result_width"].should == 1200
      result["padtop"].to_i.should == 0
      result["padbottom"].to_i.should == 0
      result["padleft"].to_i.should == 200
      result["padright"].to_i.should == 200
    end
    
    it "should return correct aspect ratio" do
      result = @p.padding(1600,900,400,300)
      result["aspect_ratio"].should == "16:9"  
      result = @p.padding(400,300,1600,900)
      result["aspect_ratio"].should == "4:3"  
    end

    it "if resize 640x480 to 320x240, it should return correct width and height" do
      result = @p.padding(320,240,640,480)
      result["result_height"].should == 240 
      result["result_width"].should == 320
    end

    it "if resize 688x368 to 320x240, it should return correct width and height" do
      result = @p.padding(320,240,688,368)
      result["result_height"].should == 172 
      result["result_width"].should == 320
      result["aspect_ratio"].should == "4:3"  
      result["padtop"].to_i.should == 34 
      result["padbottom"].to_i.should == 34 
    end
    # TODO: need to add more test cases for padding
    
  end

end
