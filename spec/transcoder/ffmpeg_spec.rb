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
  end
  
  it "should generate ffmpeg command " do        
    puts @ff.command(jobs(:kites_to_flv))
  end
  
  it  "should convert mp4 to flv" do
    # @ff.execute(jobs(:kites_to_flv))
    # File.exists? convert_file
    # convert_file.inspector.format.should == flv    
  end

  it  "should convert avi to flv" do
    # @ff.execute(jobs(:avi_to_flv))
    # File.exists? convert_file
    # convert_file.inspector.format.should == flv    
  end

  # write a generator to do this e.g.
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