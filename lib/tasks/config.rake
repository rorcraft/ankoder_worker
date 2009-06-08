namespace 'config' do
  PATHS = %W{
    config
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

    desc 'set all broker.yml, messaging.rb for production'
    task :production do |t| 
      broker = "config/template/broker.production.yml"
      messaging = "config/template/messaging.production.rb"
      PATHS.each do |path|
        `cp #{broker} #{path}/broker.yml`
        `cp #{messaging} #{path}/messaging.rb`
      end 
    end 

  end
end
