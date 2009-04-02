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
  
  FFMPEG_PATH = "/usr/local/bin/ffmpeg" unless defined? FFMPEG_PATH
  
    
  it "should generate ffmpeg command " do        
    cmd = Transcoder::Tools::FFmpeg.command(jobs(:kites_to_flv))
    cmd.should_not be_empty
    puts cmd
    `#{cmd}`
  end
  
  it "should keep same quality" do      
    cmd = Transcoder::Tools::FFmpeg.command(jobs(:kites_to_flv))
    assert cmd.match('-sameq')	  
  end

  it "should keep original size" do
    cmd = Transcoder::Tools::FFmpeg.command(jobs(:kites_to_flv))
    width = video_inspect(jobs(:kites_to_flv).original_file.file_path).width
    height= video_inspect(jobs(:kites_to_flv).original_file.file_path).height
    p cmd
    assert !cmd.include?("-s #{width}x#{height}")
  end
  
  it "should add padding if it is set"  do
    cmd = Transcoder::Tools::FFmpeg.command(jobs(:kites_to_flv320x240))
    p cmd
    assert cmd.include?("-padleft")        
  end
  
  it "should use profile size if it is set" do
    cmd = Transcoder::Tools::FFmpeg.command(jobs(:kites_to_flv320x240))
    p cmd
    assert cmd.include?("-s 320x240")    
  end

  it "run should catch ffmpeg exceptions"
  
  it  "should convert mp4 to flv" do
    Transcoder::Tools::FFmpeg.run(jobs(:kites_to_flv))
    File.should be_exists(jobs(:kites_to_flv).convert_file_full_path)
    video_inspect(jobs(:kites_to_flv).convert_file_full_path).container.should == "flv" 
    FileUtils.rm file_path
  end

  it  "should convert mp4 to flv320x240 (qvga)" do
    Transcoder::Tools::FFmpeg.run(jobs(:kites_to_flv320x240))
    File.should be_exists(jobs(:kites_to_flv).convert_file_full_path)
    video_inspect(jobs(:kites_to_flv).convert_file_full_path).width.should == "320"
    FileUtils.rm file_path
  end

  it "command should support watermark"
  
  # it  "should convert mp4 to flv852x480 (hd480)"   
  # it  "should convert mp4 to flv1280x720 (hd720)"
  # it  "should convert mp4 to flv1920x1080 (hd1080)"  

  
  # postpone
  # it "given a block, can retrieve progress"
  # it "command should support threads option when mp4"
  # it "should support 2-pass" 
    
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
  
  def video_inspect(file_path)
    RVideo::Inspector.new(:file => file_path, :ffmpeg_binary => FFMPEG_PATH)
  end
  
  
end
