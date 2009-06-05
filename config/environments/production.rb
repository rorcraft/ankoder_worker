# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!
#
if `hostname`.strip.match 'rexchung'
  AR_SITE          = 'http://mancjew:pianoman@ar.localankoder.com'
  FFMPEG_PATH      = "/opt/local/bin/ffmpeg"
  MENCODER_PATH    = "/opt/local/bin/mencoder"
  CURL             = "/usr/bin/curl"
  FILE_FOLDER      = "/Users/rexchung/workspace/ankoder/api/file_system"
  PUBLIC_FOLDER    = "/Users/rexchung/workspace/ankoder/api/public"
  THUMBNAIL_FOLDER = "/thumbnail"
else
  AR_SITE = 'http://workflow:r0rcr4ft@trunk.localankoder.com'
  FFMPEG_PATH     = "/usr/local/bin/ffmpeg"
  MENCODER_PATH   = "/usr/local/bin/mencoder"
  CURL            = "/usr/bin/curl"  
  FILE_FOLDER   = "/home/rorcraft/workspace/rorcraft_ankoder/api/file_system"
  PUBLIC_FOLDER = "/home/rorcraft/workspace/rorcraft_ankoder/api/public"
  THUMBNAIL_FOLDER = "/thumbnail"
end


S3_ON         = false
S3BUCKET = "devbucket.ankoder.com"
