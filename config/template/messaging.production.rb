#
# Add your destination definitions here
# can also be used to configure filters, and processor groups
#
# http://code.google.com/p/activemessaging/wiki/Configuration
ActiveMessaging::Gateway.define do |s|
  #s.filter :some_filter, :only=>:orders
  s.processor_group :transcoder, :transcode_worker
  s.processor_group :downloader, :downloader_worker
  s.processor_group :uploader,   :uploader_worker
    
  # NB:
  # reliable_msg "/queue/dev/Converter"
  # sqs "_queue_dev_Converter"
  
  s.destination :transcode_worker, '_queue_asqs_Converter'
  s.destination :downloader_worker, '_queue_asqs_Downloader'  
  s.destination :uploader_worker, '_queue_asqs_local_Uploader'

end
