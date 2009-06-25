# Settings specified here will take precedence over those in config/environment.rb

# config.gem "rspec", :lib => false, :version => "= 1.1.12"
# config.gem "rspec-rails", :lib => false, :version => ">= 1.1.12"

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

require 'ruby-debug'

AR_SITE       = "http://localhost"
FILE_FOLDER   = File.join RAILS_ROOT, "file_system"
S3_ON         = false
CURL            = "/usr/bin/curl"  

if `hostname` =~ /yfcai8s/
  FILE_FOLDER   = "/mnt/file_system"
  PUBLIC_FOLDER = "/Users/yfcai8/code/rorcraft/ankoderworker/public"
else
  FILE_FOLDER = "your file folder"
  PUBLIC_FOLDER="your public folder"
end

THUMBNAIL_FOLDER = "/thumbnail"
API_URL = "http://workflow:r0rcr4ft@api.localankoder.com"

if `hostname`.strip.match 'rexchung'
  FFMPEG_PATH     = "/opt/local/bin/ffmpeg"
  MENCODER_PATH   = "/opt/local/bin/mencoder"
  CURL            = "/usr/bin/curl"
else
  FFMPEG_PATH     = "/usr/local/bin/ffmpeg"
  MENCODER_PATH   = "/usr/local/bin/mencoder"
  CURL            = "/usr/bin/curl"
end

S3BUCKET = TEST_BUCKET = "ankodertest"
