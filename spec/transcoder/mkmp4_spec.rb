require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/padding")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/ffmpeg")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/mkmp4")

describe Transcoder::Tools::Mkmp4 do
  remote_fixtures

  Transcoder::Tools::FFmpeg::FFMPEG_PATH = "/opt/local/bin/ffmpeg"  
    
  it "should create mp4" do      
    Transcoder::Tools::Mkmp4.run(jobs(:kites_to_flv))
  end
  
  def test_file 
    File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites.mp4")
  end
  
end