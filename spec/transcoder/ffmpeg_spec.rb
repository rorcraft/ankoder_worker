require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/padding")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/ffmpeg")

describe Transcoder::Tools::FFmpeg do
  remote_fixtures
  # cp spec/fixtures/kites.mp4 file_system/

  Transcoder::Tools::FFmpeg::FFMPEG_PATH = "/usr/bin/ffmpeg"

    
  it "should generate ffmpeg command " do        
    cmd = Transcoder::Tools::FFmpeg.command(jobs(:kites_to_flv))
    cmd.should_not be_empty
    puts cmd
    `#{cmd}`
  end
  
  it "command should support watermark"
  
  it "command should support threads option when mp4"

  it "should support 2-pass" 
  
  it "run should catch ffmpeg exceptions"
  
  it  "should convert mp4 to flv" do
    Transcoder::Tools::FFmpeg.run(jobs(:kites_to_flv))
    file_path = File.join(FILE_FOLDER, jobs(:kites_to_flv).generate_convert_filename)
    File.should be_exists(file_path )
    # convert_file.inspector.format.should == flv 
    FileUtils.rm file_path
  end

  it "given a block, can retrieve progress"

  it  "should convert avi to flv" do
    # @ff.execute(jobs(:avi_to_flv))
    # File.exists? convert_file
    # convert_file.inspector.format.should == flv    
  end

  # TODO
  # write a generator to do this e.g. (need to create a bunch of XML files)
  # from = %w{ mp4 avi flv wmv mov ogg divx m4v rmvb }
  # to = %{ mp4 avi flv wmv ogg divx m4v }
  # from.each do |f| 
  #   to.each do |t|
  #     eval %{ it "should convert #{f} to #{t}" do
  #                @ff.execute(jobs(:#{f}_to_#{t}))
  #                \# file exists
  #                \# inspect
  #             end
  #           }
  #    end
  # end
    
    
  def test_file 
    File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites.mp4")
  end
  
end
