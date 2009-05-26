require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/padding")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/yamdi")
require "rvideo"
describe Transcoder::Tools::Yamdi do
  remote_fixtures
  
  YAMDI_PATH = "/usr/local/bin/yamdi" unless defined? YAMDI_PATH
  
  it "should generate yamdi command " do        
    cmd = Transcoder::Tools::Yamdi.command(path(jobs(:kites_to_flv)))
    cmd.should_not be_empty
    puts cmd
    `#{cmd}`
  end
  
  #it "should raise exception when the file is invalid" do      
    #lambda{Transcoder::Tools::Yamdi.run(path(:kites_to_mpg))}.should raise_error
  #end

  #it "should be 00:00:00 in duration before processing" do
   #video_inspect(path(:kites_to_flv)).duration.should == "00:00:00" 
  #end

  
  def test_file 
    File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites.mp4")
  end

  def path(job)
    job.generate_convert_filename 
  end
  
  def video_inspect(file_path)
    RVideo::Inspector.new(:file => file_path, :ffmpeg_binary => FFMPEG_PATH)
  end
  
end
