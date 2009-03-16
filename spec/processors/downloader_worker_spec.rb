require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/activemessaging/lib/activemessaging/test_helper'
require File.dirname(__FILE__) + '/../../app/processors/application'


describe DownloaderProcessor do
  
  include ActiveMessaging::TestHelper  
  remote_fixtures
  
  before :each do
    @proc = Downloader.Processor.new
  end
  
  
  it "should listen to message" do
    @proc.on_message("")
  end
  
  
end