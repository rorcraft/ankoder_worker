require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/padding")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/ffmpeg")

describe Transcoder::Tools::Mencoder do
  remote_fixtures
  # cp spec/fixtures/kites.mp4 file_system/
  
  class TestMencoder
    Transcoder::Tools::Mencoder::MENCODER_PATH = "/usr/bin/mencoder"
    include Transcoder::Tools::Mencoder
       
    attr_accessor :video, :profile, :job                
  end
  
  before :each do
    @mm = TestMencoder.new    
  end
  
  it "proprocess_command should generate command " do        
    cmd = @mm.preprocess_command(jobs(:kites_to_flv))
    cmd.should_not be_empty
    puts cmd
  end
  
  it "should preprocess" do
    @mm.preprocess(jobs(:kites_to_flv))
  end    
    
  def test_file 
    File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites.mp4")
  end
  
end
