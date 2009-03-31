require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/padding")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/ffmpeg")
require "rvideo"
describe Transcoder::Tools::FFmpeg do
  remote_fixtures
  # mkdir file_system && cp spec/fixtures/kites.mp4 file_system/
  
  FFMPEG_PATH = "/usr/local/bin/ffmpeg" unless defined? "FFMPEG_PATH"
  
    
  it "should generate ffmpeg command " do        
    cmd = Transcoder::Tools::FFmpeg.command(jobs(:kites_to_flv))
    cmd.should_not be_empty
    puts cmd
    `#{cmd}`
  end
  
#   it "command should support watermark"

  it "should keep same quality" do
    original_file = jobs(:kites_to_flv).original_file	  
    original_inspector = RVideo::Inspector.new(:file=> original_file.file_path, :ffmpeg_binary => FFMPEG_PATH)
    Transcoder::Tools::FFmpeg.run(jobs(:kites_to_flv))
    				  
    File.should be_exists(jobs(:kites_to_flv).convert_file_full_path)    
    # debugger
    converted_inspector = RVideo::Inspector.new(:file => jobs(:kites_to_flv).convert_file_full_path, :ffmpeg_binary => FFMPEG_PATH)

    original_inspector.bitrate.should <= converted_inspector.bitrate.to_i 
    puts original_inspector.bitrate
    puts original_inspector.fps

  end
  # it "command should support threads option when mp4"

  # it "should support 2-pass" 
  
  it "run should catch ffmpeg exceptions"
  
  it  "should convert mp4 to flv" do
    Transcoder::Tools::FFmpeg.run(jobs(:kites_to_flv))
    file_path = File.join(FILE_FOLDER, jobs(:kites_to_flv).generate_convert_filename)
    File.should be_exists(file_path)
    File.size(file_path).should > 0 
#     FileUtils.rm file_path
  end
  
  it "given a block, can retrieve progress"

  # TODO
  # write a generator to do this e.g. (need to create a bunch of XML files)
#   it "should convert mp4 to other formats" do
#     debugger
#     from = ["mp4"]
#     to = ["divx", "flv", "mov", "rm", "wmv"]
#     from.each do |f| 
#       to.each do |t|
#         eval %{ it "should convert #{f} to #{t}" do
#                  @ff.execute(jobs(:#{f}_to_#{t}))
#                  file_path = File.join(FILE_FOLDER, jobs(:#{f}_to_#{t}).generate_convert_filename)
#                  File.should be_exists(file_path)
#               end
#             }
#       end
#     end
#   end
    
    
  def test_file 
    file_path = File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites.mp4")
#     `gnome-open $file_path`
  end
  
end
