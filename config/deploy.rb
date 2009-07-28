# set :default_stage, "ec2-server2"
set :stages, %w(staging production ec2-server2 localec2 ec2_cluster local ec2-server1 ec2-new-worker)
require 'capistrano/ext/multistage'

set :repository_cache, "svn_trunk"
set :deploy_via, :remote_cache
set :use_sudo, false
set :whenever, "whenever"

# Make symlink for for app
after "deploy:symlink", "app:symlink", "app:rake_and_update_crontab", "deploy:restart"

namespace :app do
  task :symlink do
    sudo "mkdir -p /mnt/file_system"
    sudo "chown #{user} /mnt/file_system"
    run "ln -s /mnt/file_system #{deploy_to}/current/file_system"
    run "cd #{deploy_to}/current/config && rm -f database.yml && ln -s #{shared_path}/svn_trunk/config/database.yml"
  end

  desc "Rake & Update crontabe"
  task :rake_and_update_crontab, :roles => :db do
    # order dependency
    run "cd #{current_path} && rake config:messaging:#{rails_env}"
    run "cd #{current_path} && rake config:environment:#{rails_env}"
    run "cd #{current_path} && sudo rake gems:install"
    run "cd #{current_path} && #{whenever} --update-crontab #{application}"
  end
end         

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "sudo apache2ctl restart" #"touch #{current_path}/tmp/restart.txt"
  end 
              
  [:start, :stop].each do |t| 
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end 
  end 
end 
