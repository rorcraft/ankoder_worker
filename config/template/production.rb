# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

AR_SITE = 'http://workflow:r0rcr4ft@ar.ankoder.com'
FFMPEG_PATH     = "/usr/local/bin/ffmpeg"
AXEL_PATH = "/usr/local/bin/axel"
FFMPEG2THEORA_PATH     = "/usr/local/bin/ffmpeg2theora"
MENCODER_PATH   = "/usr/local/bin/mencoder"
CURL            = "/usr/bin/curl"
FILE_FOLDER   = "/var/www/ankoderworker/current/file_system"
PUBLIC_FOLDER = "/var/www/ankoderworker/current/public"
THUMBNAIL_FOLDER = "/thumbnail"

SEGMENTER_PATH = "/usr/local/bin/commit.segfault"
VHOOK_WATERMARK_PATH = "/home/railsdeploy/ffmpegvhook/vhook/watermark.so"
FFMPEG_WITH_VHOOK_PATH = "/home/railsdeploy/ffmpegvhook/ffmpeg"

S3_ON         = true
S3BUCKET = S3_BUCKET = "download.ankoder.com"

ACCESS_KEY_ID     = "04WAVZJW4HAZZQTWKCR2"
SECRET_ACCESS_KEY = "/iEjATrlFcU9k7pyPQSWjtfI8AnylH1CXs33TrvI"

S3_SERVER         = "s3.amazonaws.com"
