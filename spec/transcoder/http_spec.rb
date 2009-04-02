require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/transcoder")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/tools/http")

describe Transcoder::Tools::Http do
  remote_fixtures

    
  # watch request from localhost:3000
  

  it "should postback fail message" do
    result = Transcoder::Tools::Http.post_back(jobs(:kites_to_divx), "fail")
  end
    
  it "should postback success message" do
    result = Transcoder::Tools::Http.post_back(jobs(:kites_to_divx), "success")
  end
    
end
