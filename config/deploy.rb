set :default_stage, "ec2-server2"
set :stages, %w(staging production ec2-server2 localec2 ec2_cluster local ec2-server1)
require 'capistrano/ext/multistage'

set :repository_cache, "svn_trunk"
set :deploy_via, :remote_cache
set :use_sudo, false

# Make symlink for for app
after "deploy:symlink", "app:symlink"
namespace :app do
  task :symlink do
    sudo "mkdir -p /mnt/file_system"
    sudo "chown #{user} /mnt/file_system"
    run "ln -s /mnt/file_system #{deploy_to}/current/file_system"
    #run "cd #{deploy_to}/current/config && rm -f mongrel_cluster.yml && ln -s #{shared_path}/svn_trunk/config/mongrel_cluster.yml"
    run "cd #{deploy_to}/current/config && rm -f database.yml && ln -s #{shared_path}/svn_trunk/config/database.yml"
  end
end         

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end 
              
  [:start, :stop].each do |t| 
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end 
  end 
end 
