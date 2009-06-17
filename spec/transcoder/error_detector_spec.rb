require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/error_detector")

describe ErrorDetector do

  file = '/tmp/useless_file'

  it 'should detect non-existent s3 bucket' do
    e = ErrorDetector.new 'curl', 's3'
    output = `curl -v -# s3.amazonaws.com/testVideo/foulfiend 2>&1`
    error = assert_raise RuntimeError do
      e.check_for_error output
    end
    assert_equal error.message, '404'
  end

  it 'should detect non-existent host' do
    e = ErrorDetector.new 'curl', 'http'
    error = assert_raise RuntimeError do
      e.check_for_error `curl asdfasdfasdfasdf 2>&1`
    end
    puts error
    e = ErrorDetector.new 'axel', 'http'
    error = assert_raise RuntimeError do
      e.check_for_error `axel asdfasdfasdfasdf 2>&1`
    end
    puts error
    e = ErrorDetector.new 'scp', 'sftp'
    error = assert_raise RuntimeError do
      e.check_for_error `scp asdfasdfasdf:asdf asdf 2>&1`
    end
    puts error
  end

  it 'should detect curl http error' do
    e = ErrorDetector.new 'curl', 'http'
    error = assert_raise RuntimeError do
      e.check_for_error `curl -v -# http://www.cse.cuhk.edu.hk/blah_blah 2>&1`
    end
    assert_equal error.message, '404'
  end

  it 'should detect axel http error' do
    e = ErrorDetector.new 'axel', 'http'
    error = assert_raise RuntimeError do
      e.check_for_error `axel http://www.cse.cuhk.edu.hk/corner 2>&1`
    end
    assert_equal error.message, '401'
  end

  it 'should detect curl ftp error' do
    e = ErrorDetector.new 'curl', 'ftp'
    error = assert_raise RuntimeError do
      e.check_for_error `curl ftp://ftp.filekeeper.org/ 2>&1`
    end
    assert_equal error.message, ErrorDetector::ACCESS_DENIED
  end

  it 'should detect axel ftp error' do
    e = ErrorDetector.new 'axel', 'ftp'
    error = assert_raise RuntimeError do
      e.check_for_error `axel ftp://ftp.filekeeper.org/ 2>&1`
    end
    assert_equal error.message, ErrorDetector::ACCESS_DENIED
  end

  it 'should detect sftp error' do
    e = ErrorDetector.new 'scp', 'sftp'
    error = assert_raise RuntimeError do
      e.check_for_error `scp -B yfcai8@gw.cse.cuhk.edu.hk:./.vimrc . 2>&1`
    end
    assert_equal error.message, ErrorDetector::ACCESS_DENIED
  end

end
