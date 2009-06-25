# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

S3_ON = false

S3_BUCKET = S3BUCKET = "devbucket2.ankoder.com"
ACCESS_KEY_ID     = "04WAVZJW4HAZZQTWKCR2"
SECRET_ACCESS_KEY = "/iEjATrlFcU9k7pyPQSWjtfI8AnylH1CXs33TrvI"
S3_SERVER         = "s3.amazonaws.com"

API_URL = "http://workflow:r0rcr4ft@api.localankoder.com"

if `hostname`.strip.match 'rexchung'
  AR_SITE          = 'http://mancjew:pianoman@ar.localankoder.com'
  FFMPEG_PATH      = "/opt/local/bin/ffmpeg"
  MENCODER_PATH    = "/opt/local/bin/mencoder"
  CURL             = "/usr/bin/curl"
  FILE_FOLDER      = "/Users/rexchung/workspace/ankoder/api/file_system"
  PUBLIC_FOLDER    = "/Users/rexchung/workspace/ankoder/api/public"
  THUMBNAIL_FOLDER = "/thumbnail"
else
  AR_SITE = 'http://workflow:r0rcr4ft@ar.localankoder.com'
  FFMPEG_PATH     = "/usr/local/bin/ffmpeg"
  MENCODER_PATH   = "/usr/local/bin/mencoder"
  MP4BOX_PATH     = "/usr/local/bin/MP4Box"
  CURL            = "/usr/bin/curl"  
  FILE_FOLDER   = "/Users/yfcai8/code/rorcraft/rorcraft_ankoder/api/file_system"
  PUBLIC_FOLDER = "/Users/yfcai8/code/rorcraft/rorcraft_ankoder/api/public"
  THUMBNAIL_FOLDER = "/thumbnail"
end
