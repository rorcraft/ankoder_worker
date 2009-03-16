
require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/padding")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/ffmpeg")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/flvtool2")

describe Transcoder::Tools::Flvtool2 do
  remote_fixtures

  Transcoder::Tools::Flvtool2::FLVTOOL_PATH = "/opt/local/bin/flvtool"  
    
  it "should create mp4" do      
    Transcoder::Tools::Flvtool2.add_title(jobs(:kites_to_flv))
  end
  
  def test_file 
    File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites.mp4")
  end
  
end