require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/activemessaging/lib/activemessaging/test_helper'
require File.dirname(__FILE__) + '/../../app/processors/application'

class DownloaderProcessorTest < Test::Unit::TestCase
  include ActiveMessaging::TestHelper
  
  def setup
    @processor = DownloaderProcessor.new
  end
  
  def teardown
    @processor = nil
  end  

  def test_downloader_processor
    @processor.on_message('Your test message here!')
  end
end