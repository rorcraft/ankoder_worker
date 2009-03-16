require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")

describe Transcoder::Tools::QtFaststart do
  remote_fixtures

    
  it "should " do      
    Transcoder::Tools::QtFaststart.run(jobs(:kites_to_flv)) # TODO: should be to m4v job
    # how to check?
    # play m4v in flash
  end
  
  def test_file 
    File.expand_path(File.dirname(__FILE__) + "/../fixtures/kites.mp4")
  end
  
end