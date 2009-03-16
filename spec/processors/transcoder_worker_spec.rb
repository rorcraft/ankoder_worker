require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/activemessaging/lib/activemessaging/test_helper'
require File.dirname(__FILE__) + '/../../app/processors/application'
require File.dirname(__FILE__) + '/../../app/processors/transcode_worker_processor'

describe TranscodeWorkerProcessor do
  
  include ActiveMessaging::TestHelper  
  remote_fixtures
  
  before :each do
    @proc = TranscodeWorkerProcessor.new
  end
  
  it "should get job id" do
    @proc.get_job_id(message).should == jobs(:kites_to_flv).id.to_s
  end
  
  it "should listen to message" do
    # mock(Transcoder::Tools::FFmpeg).should_expect(:run)
    @proc.on_message(message)
  end
  
  # test all different formats here as well.
  
  
   
  
end

# e.g. message({"content" => { "config" => {"ConvertJob" => jobs(:kites_to_3gp).id}}})
def message(options = {})
  # should use recursive merge here. ( From rorcraft helper )
  options = {"type"=>"ASSIGN" , "content" => {"node_name" => "Converter" , "config" => {"OriginalFile"=> videos(:kites).id ,"ConvertJob" => jobs(:kites_to_flv).id  } }}.merge!(options)
  options.to_json
end