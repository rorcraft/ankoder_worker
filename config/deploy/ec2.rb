set :application, "ankoderworker"
set :repository,  "git@rorcraft.unfuddle.com:rorcraft/ankoderworker.git"
default_run_options[:pty] = true

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/workflow/project/ankoderworker"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :branch, "master"
set :git_enable_submodules, 1
set :git_shallow_clone, 1

set :scm_username, "railsdeploy"
set :scm_password, "r0rcr4ft"
set :scm_passphrase, ""

set :scm_verbose, true

#set :ssh_options, { :forward_agent => true , :keys => ["/home/workflow/.ssh/id_rsa"] }
ssh_options[:forward_agent] = true

set :user, 'workflow'
set :password, 'rubyonrails'
set :deploy_via, :remote_cache


role :app, "ec2.localankoder.com"
role :web, "ec2.localankoder.com"
role :db,  "ec2.localankoder.com", :primary => true