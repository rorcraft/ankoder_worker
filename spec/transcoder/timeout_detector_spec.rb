require 'active_support'
require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/transcoder/helper")
require File.expand_path(File.dirname(__FILE__) + "/../../lib/timeout_detector")

describe TimeoutDetector do
  TimeoutDetector.const_set 'DETECTOR_POLL_INTERVAL_SEC', 1
  TimeoutDetector.const_set 'DETECTOR_TIMEOUT_SEC', 3

  it 'should detect non-existent file' do
    t = nil
    error = assert_raise RuntimeError do
      t = TimeoutDetector.new '/this.file.does.not.exist'
      sleep 4
    end
    assert t
    if t
      t.exit
      puts error.message
    end
  end

  it 'detect unchanged file' do
    t = nil
    file = '/tmp/useless_file'
    `touch #{file}`
    error = assert_raise RuntimeError do
      t = TimeoutDetector.new file
      sleep 4
    end
    assert t
    if t
      t.exit
      puts error.message
      File.delete file
    end
  end

  it 'detect changed file' do
    t = nil
    file = '/tmp/useless_file'
    `touch #{file}`
    assert_nothing_raised do
      t = TimeoutDetector.new file
      5.times do
        `echo "b" >> #{file}`
        sleep 1
      end
    end
    t.exit if t
    File.delete file
  end
end
