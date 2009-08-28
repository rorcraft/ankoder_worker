# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

AR_SITE = 'http://workflow:r0rcr4ft@ar.localankoder.com'
FFMPEG_PATH     = "/usr/local/bin/ffmpeg"
FFMPEG2THEORA_PATH     = "/usr/local/bin/ffmpeg2theora"
MENCODER_PATH   = "/usr/local/bin/mencoder"
AXEL_PATH = "/usr/local/bin/axel"
CURL            = "/usr/bin/curl"  
FILE_FOLDER   = "/var/www/api_ankoder/current/file_system"
PUBLIC_FOLDER = "/var/www/api_ankoder/current/public"
THUMBNAIL_FOLDER = "/thumbnail"

SEGMENTER_PATH = "/usr/local/bin/commit.segfault"
VHOOK_WATERMARK_PATH = "/home/softie/ffmpegvhook/vhook/watermark.so"
FFMPEG_WITH_VHOOK_PATH = "/home/softie/ffmpegvhook/ffmpeg"

S3_ON         = false
S3BUCKET = S3_BUCKET = "devbucket.ankoder.com"

S3_SERVER         = "s3.amazonaws.com"
