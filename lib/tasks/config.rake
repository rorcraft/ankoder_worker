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
      copy 'production'
    end 

    desc 'set all broker.yml, messaging.rb for localproduction'
    task :localproduction do |t| 
      copy 'localproduction'
    end 

  end

  namespace 'environment' do
    def copy_env state
      file = "config/template/#{state}.rb"
      PATHS.each do |path|
        `cp #{file} #{path}/environments/production.rb`
      end
    end

    desc 'set environments/production.rb for ec2'
    task :production do |t| 
      copy_env 'production'
    end 

    desc 'set environments/production.rb for local deployment'
    task :localproduction do |t| 
      copy_env 'localproduction'
    end 

  end
end
