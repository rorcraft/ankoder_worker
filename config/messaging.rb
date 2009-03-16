#
# Add your destination definitions here
# can also be used to configure filters, and processor groups
#
# http://code.google.com/p/activemessaging/wiki/Configuration
ActiveMessaging::Gateway.define do |s|
  #s.filter :some_filter, :only=>:orders
  s.processor_group :transcoder, :transcoder_worker
  s.processor_group :downloader, :downloader
    
  s.destination :transcode_worker, '/queue/Converter'
  s.destination :downloader, '/queue/Downloader'  
end