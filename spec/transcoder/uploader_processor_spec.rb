require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/downloader")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/timeout_detector")
require File.expand_path(File.dirname(__FILE__) +
                         "/../../app/processors/uploader_processor.rb")
require 'socket'
require 'cgi'
include Socket::Constants

class Video
  def save
    # purposefully do nothing
  end
end

describe Uploader do
  remote_fixtures

  `touch #{FILE_FOLDER}/b`

  begin
    @@socket = Socket.new( AF_INET, SOCK_STREAM, IPPROTO_TCP )
    @@socket.bind(Socket.pack_sockaddr_in( 5555, '127.0.0.1' ))
    @@socket.listen( 5 ) 
  rescue
    puts 'Server socket in TIME_WAIT stage. Please wait a while.'
    exit 1
  end

  def read_socket
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
  def message(id)
    return {'video_id'=>id}.to_json
  end

  def get_processor
    UploaderProcessor.new
  end

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

  it 'should report unreachable host' do
    check(139,'fail','Upload URL unreachable')
  end

  it 'should report denied access' do
    check(530,'fail','Authentication failed')
  end

  it 'should timeout'

  it 'should react to random url' do
    error = check(975,'fail',nil,true)
    assert !error.blank?
    puts error
  end

  #`rm #{FILE_FOLDER}/b`
end
