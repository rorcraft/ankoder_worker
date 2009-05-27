require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/padding")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/mp4box")
require "rvideo"
describe Transcoder::Tools::Mp4box do
  remote_fixtures
  
  MP4BOX_PATH = "/usr/bin/MP4Box" unless defined? MP4BOX_PATH
  FFMPEG_PATH = "/usr/local/bin/ffmpeg" unless defined? FFMPEG_PATH
  
  it "should generate MP4Box command " do        
    cmd = Transcoder::Tools::Mp4box.command(temp_file)
    cmd.should_not be_empty
    puts cmd
  end
  
  #it "should be 00:00:00 in duration before processing" do
    #video_inspect(temp_file).duration.should == 0
  #end

  def temp_file 
    infile = File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites.flv")
    outfile = File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites_tmp.flv")
    FileUtils.cp infile, outfile
    return outfile
  end

  def video_inspect(file_path)
    RVideo::Inspector.new(:file => file_path, :ffmpeg_binary => FFMPEG_PATH)
  end
  
end
