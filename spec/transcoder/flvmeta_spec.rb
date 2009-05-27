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
  FFMPEG_PATH = "/usr/local/bin/ffmpeg" unless defined? FFMPEG_PATH   
  
  it "should generate yamdi command " do        
    cmd = Transcoder::Tools::Yamdi.command(temp_file)
    cmd.should_not be_empty
    puts cmd
  end
  
  it "should raise exception when the file is invalid" do      
    lambda{Transcoder::Tools::Yamdi.run(jobs(:kites_to_mov).convert_file_full_path)}.should raise_error Transcoder::TranscoderError::MetaInjectionException
  end

  it "should be 00:00:00 in duration before processing" do
    video_inspect(temp_file).duration.should == 0
  end

  it "should not be 00:00:00 in duration after processing" do
    outfile = temp_file
    Transcoder::Tools::Yamdi.run(outfile)
    video_inspect(outfile).duration.should_not == 0
  end
  
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
