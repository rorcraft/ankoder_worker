# Be sure to restart your server when you modify this file

RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  require 'aws/s3'
  config.gem "reliable-msg", :lib => "reliable-msg"
  config.gem "json", :lib => "json"
  config.gem "rvideo", :lib => "rvideo", :version => "1.0.0", :source => "git://github.com/jagthedrummer/rvideo.git"
  config.gem "image_science", :lib => "image_science"
  config.gem "cronic"
  config.gem 'javan-whenever', :lib => false, :source => 'http://gems.github.com'

  config.time_zone = 'UTC'
end

Rails.logger.auto_flushing = 1

MAX_S3_UPLOAD_TRIES = 3
