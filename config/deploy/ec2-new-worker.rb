NEW_WORKER_HOSTNAME = "ec2-174-129-141-222.compute-1.amazonaws.com"

set :rails_env,   "production"
set :application, "ankoderworker"
set :repository,  "git@rorcraft.unfuddle.com:rorcraft/ankoderworker.git"
default_run_options[:pty] = true

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/ankoderworker"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :branch, "master"
set :git_enable_submodules, 1
set :git_shallow_clone, 1

set :whenever, "/usr/local/ruby-enterprise/lib/ruby/gems/1.8/gems/javan-whenever-0.3.6/bin/whenever"

set :scm_username, "railsdeploy"
set :scm_password, "r0rcr4ft"
set :scm_passphrase, ""

set :scm_verbose, true

#set :ssh_options, { :forward_agent => true , :keys => ["/home/workflow/.ssh/id_rsa"] }
ssh_options[:forward_agent] = true

set :user, 'railsdeploy'
set :password, 'railsonruby'
set :deploy_via, :remote_cache

role :app, NEW_WORKER_HOSTNAME
role :web, NEW_WORKER_HOSTNAME
role :db,  NEW_WORKER_HOSTNAME, :primary => true
