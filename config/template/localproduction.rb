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
AR_SITE = 'http://workflow:r0rcr4ft@ar.localankoder.com'
FFMPEG_PATH     = "/usr/local/bin/ffmpeg"
MENCODER_PATH   = "/usr/local/bin/mencoder"
CURL            = "/usr/bin/curl"  
FILE_FOLDER   = "/var/www/api_ankoder/current/file_system"
PUBLIC_FOLDER = "/var/www/api_ankoder/current/public"
THUMBNAIL_FOLDER = "/thumbnail"

S3_ON         = false
S3BUCKET = "devbucket.ankoder.com"
