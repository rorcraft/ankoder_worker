#
# Add your destination definitions here
# can also be used to configure filters, and processor groups
#
# http://code.google.com/p/activemessaging/wiki/Configuration
ActiveMessaging::Gateway.define do |s|
  #s.filter :some_filter, :only=>:orders
  s.processor_group :transcoder, :transcoder_worker
  s.processor_group :downloader, :downloader_worker
    
  # NB:
  # reliable_msg "/queue/dev/Converter"
  # sqs "_queue_dev_Converter"
  
  if ENV['RAILS_ENV'] != "production"
    s.destination :transcode_worker, '/queue/dev/Converter' 
    s.destination :downloader_worker, '/queue/dev/Downloader'  
  else
    s.destination :transcode_worker, '_queue_Converter'
    s.destination :downloader_worker, '_queue_Downloader'  
  end

end
