require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/../lib/video_site_url_parse")

class VideoSiteUrlParseTest < Test::Unit::TestCase
  # Replace this with your real tests.
  include VideoSiteUrlParse

  def test_parse_tudou
    url = parse_video_url "http://hd.tudou.com/program/7076/"    
    puts url
  end
  
  
end
