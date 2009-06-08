namespace 'config' do
  PATHS = %W{
    config
    ../api/config
    ../developer/config
  }

  namespace 'messaging' do
    def copy state
      broker = "config/template/broker.#{state}.yml"
      messaging = "config/template/messaging.#{state}.rb"
      PATHS.each do |path|
        `cp #{broker} #{path}/broker.yml`
        `cp #{messaging} #{path}/messaging.rb`
      end
    end
     
    desc 'set all broker.yml, messaging.rb to use reliable messaging'
    task :reliable do |t|
      copy 'reliable'
    end

    desc 'set all broker.yml. messaging.rb to use sqs'
    task :sqs do |t|
      copy 'sqs'
    end
  end
end
