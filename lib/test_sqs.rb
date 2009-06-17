class TestSqs 
  
  class << self
    include ActiveMessaging::MessageSender  
    publishes_to :downloader_worker
  end
  
  def self.send_msg
    message = {"type"=>"ASSIGN" , "content" => {"node_name" => "Downloader" , "config" => {"OriginalFile"=> 199 } }}.to_json    
    publish :downloader_worker, message
  end
  
  def self.right_send_msg
    message = {"type"=>"ASSIGN" , "content" => {"node_name" => "Downloader" , "config" => {"OriginalFile"=> 199 } }}.to_json    
    @sqs = right_sqs
    @sqs.queue("_queue_dev_Downloader").send_message(message)
  end
  
  def self.right_sqs2
    RightAws::SqsGen2.new("04WAVZJW4HAZZQTWKCR2", "/iEjATrlFcU9k7pyPQSWjtfI8AnylH1CXs33TrvI")
  end

  def self.right_sqs
    RightAws::Sqs.new("04WAVZJW4HAZZQTWKCR2", "/iEjATrlFcU9k7pyPQSWjtfI8AnylH1CXs33TrvI")
  end
  
end