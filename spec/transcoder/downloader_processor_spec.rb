require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/downloader")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/timeout_detector")
require File.expand_path(File.dirname(__FILE__) +
                         "/../../app/processors/downloader_processor.rb")
require 'socket'
require 'cgi'
include Socket::Constants

class Video
  def save     # mock method
  end
end

describe DownloaderProcessor do
  remote_fixtures

  begin
    @@socket = Socket.new( AF_INET, SOCK_STREAM, IPPROTO_TCP )
    @@socket.bind(Socket.pack_sockaddr_in( 5555, '127.0.0.1' ))
    @@socket.listen( 5 ) 
  rescue
    puts 'Server socket in TIME_WAIT stage. Please wait a while.'
    exit 1
  end

  def read_socket #receive postback into params hash 
    s = @@socket.accept[0]
    sleep 1
    string = s.recvfrom(65536)[0]
    s.close
    a = string.split("\r\n\r\n")
    a.delete_at(0)
    c = CGI.parse(a.join)
    c.keys.each do |key|
      c[key] = c[key].join
    end
    return c
  end

  # video id hard-coded. relies on remote fixture.
  def message(id=1997)
    return { "type"=>"ASSIGN" ,
        "content" => {"node_name" => "Downloader",
          "config" => {"OriginalFile" => id} }}.to_json
  end

  def get_processor
    DownloaderProcessor.new
  end

  # check if message is expected
  def check(id, rslt, error='', return_error_message = false)
    p = get_processor
    Thread.start do
      p.on_message(message(id))
    end
    params = read_socket
    assert(params['message'] =~ /"result":"([^"]*)"/)
    assert_equal rslt, $1
    assert(params['message'] =~ /"error":"([^"]*)"/)
    assert_equal error, $1 unless return_error_message
    return $1
  end

  it 'should work' do # costs 30 sec
    check(1997,'success')
  end

  it 'should 404' do
    check(404,'fail','HTTP status 404')
  end

  it 'should report bad video' do
    check(139,'fail','The downloaded file is not a supported video')
  end

  it 'should report unreachable host' do
    check(640,'fail','Download URL unreachable')
  end

  it 'should report denied access' do
    check(530,'fail','Authentication failed')
  end

  it 'should timeout' do
    poll_interval = TimeoutDetector::DETECTOR_POLL_INTERVAL_SEC
    timeout = TimeoutDetector::DETECTOR_TIMEOUT_SEC
    TimeoutDetector.const_set 'DETECTOR_POLL_INTERVAL_SEC', 1
    TimeoutDetector.const_set 'DETECTOR_TIMEOUT_SEC', 3
    p = get_processor
    Thread.start do
      p.on_message(message(774))
    end
    s = @@socket.accept[0]
    sleep 5
    s.close
    params = read_socket
    assert(params['message'] =~ /"result":"([^"]*)"/)
    assert_equal 'fail', $1
    assert(params['message'] =~ /"error":"([^"]*)"/)
    assert_equal 'Download connection timed out', $1
    TimeoutDetector.const_set 'DETECTOR_POLL_INTERVAL_SEC', poll_interval
    TimeoutDetector.const_set 'DETECTOR_TIMEOUT_SEC', timeout
  end

  it 'should react to random url' do
    error = check(975,'fail',nil,true)
    assert !error.blank?
    puts error
  end

end
