require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/padding")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/ffmpeg")

describe Transcoder::FFmpeg do
  remote_fixtures
  
  class TestFFmpeg
    Transcoder::FFmpeg::FFMPEG_PATH = "/opt/local/bin/ffmpeg"
    include Transcoder::FFmpeg
       
    attr_accessor :video, :profile, :job                
  end
  
  before :each do
    @ff = TestFFmpeg.new    
    @ff.video = videos(:kites)
    @ff.profile = profiles(:flv)
    @ff.job = jobs(:kites_to_flv)
  end
  
  it "should generate ffmpeg command " do
        
    puts @ff.command(@ff.job)
  end
  
  def test_file 
    File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites.mp4")
  end
  
end