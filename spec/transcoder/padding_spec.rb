#require 'active_support'
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

  it "float_to_even_int should make (positive) floats to the best even integer" do
    @p.float_to_even_int(13.5).should == 14
    @p.float_to_even_int(12.5).should == 12
    @p.float_to_even_int(10.999999).should == 10
    @p.float_to_even_int(0.999999).should == 0
  end

  it "split_padding should split padding according to the width and height of target and original" do
    #height test
    @p.split_padding(300, 600, 480, 640).should == [80,80,320]
    @p.split_padding(214, 320, 144, 176).should == [14,14,116] # h263 bug test case

    #width test
    @p.split_padding(15, 13, 20, 14).should == [2,2,16]
  end

  describe ".padding(profile_width,profile_height,video_width,video_height)" do
    it "defaults to 320x240" do
      result = @p.padding(0,0,-1,-1)
      result["result_height"].should == 240
      result["result_width"].should == 320
    end

    it "should not break on zeros" do
      result = @p.padding(0,0,0,0)
      #result["result_height"].should == 0
      #result["result_width"].should == 0
    end

    it "should always return integer values" do
      result = @p.padding(123,456,789,234)
      result["result_height"].should.type == Fixnum
      result["result_width"].should.type == Fixnum
      result["padtop"].should.type == Fixnum
      result["padbottom"].should.type == Fixnum
      result["padleft"].should.type == Fixnum
      result["padright"].should.type == Fixnum

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

    it "if profile dimensions = video dimensions it should return the same dimensions" do
      result = @p.padding(320,240,320,240)
      result["result_height"].should == 240
      result["result_width"].should == 320
      result["padtop"].to_i.should == 0
      result["padbottom"].to_i.should == 0
      result["padleft"].to_i.should == 0
      result["padright"].to_i.should == 0
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

    it "if profile = 4:3, video = 16:9 it'll pad height" do
      result = @p.padding(640,480,1920,1080)
      result["result_height"].should == 360
      result["result_width"].should == 640
      result["padtop"].to_i.should == 60
      result["padbottom"].to_i.should == 60
      result["padleft"].to_i.should == 0
      result["padright"].to_i.should == 0
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

    it "profile width = 2 and profile height = 2 should give sensible results" do
      result = @p.padding(2,2,640,480)
      result["result_height"].should == 2
      result["result_width"].should == 2
    end

    it "if resize 688x368 to 320x240, it should return correct width and height" do
      result = @p.padding(320,240,688,368)
      result["result_height"].should == 172
      result["result_width"].should == 320
      result["aspect_ratio"].should == "4:3"
      result["padtop"].to_i.should == 34
      result["padbottom"].to_i.should == 34
    end

    it "should correct odd width and height to something even" do
      result = @p.padding(320,240,687,367)
      result["result_width"].should == 320
      result["aspect_ratio"].should == "4:3"
      (result["result_height"]+result["padtop"].to_i+result["padbottom"].to_i).should == 240
    end

    it "should handle near-to-zero width and heights" do
      result1 = @p.padding(320,240,1,2)
      result1["result_height"].should == 240
      result2 = @p.padding(320,240,2,1)
      result2["result_width"].should == 320
    end

    it "should return standard CIF files for h263" do # h263 bug test case
      result = @p.padding(176, 144, 320, 214)
      result["result_height"].should == 116
      result["result_width"].should == 176
      (result["result_height"]+result["padtop"].to_i+result["padbottom"].to_i).should == 144
    end
    # TODO: need to add more test cases for padding

  end

end
