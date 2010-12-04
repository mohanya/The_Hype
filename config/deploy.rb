# Please install the Engine Yard Capistrano gem
# gem install eycap --source http://gems.engineyard.com
require "eycap/recipes"
set :stages, %w(itg pro)
require 'capistrano/ext/multistage'

set :keep_releases, 5
set :application,   'The_Hype'
set :repository,    'git@github.com:thehype/The_Hype.git'
set :deploy_to,     "/data/#{application}"
set :deploy_via,    :export
set :monit_group,   "#{application}"
set :scm,           :git
set :git_enable_submodules, 1
# This is the same database name for all environments
set :production_database,'The_Hype_production'

set :environment_host, 'localhost'
set :deploy_via, :remote_cache

# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
default_run_options[:pty] = true # required for svn+ssh:// andf git:// sometimes

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, 			lambda { source.query_revision(revision) { |cmd| capture(cmd) } }

# TASKS
# Don't change unless you know what you are doing!

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"

namespace :nginx do
  task :start, :roles => :app do
    sudo "nohup /etc/init.d/nginx start > /dev/null"
  end

  task :restart, :roles => :app do
    sudo "nohup /etc/init.d/nginx restart > /dev/null"
  end
end

namespace :deploy do
  
  task :default do
    set(:branch) do
      br = Capistrano::CLI.ui.ask "What branch do you want to deploy? (Currently, we are only deploying from the 'deploy' branch): ".downcase
      raise "Cannot deploy master branch to production." if (stage.to_s.upcase == 'PRO') && br == 'master'
      br
    end
    update
    restart
    # 
    # # cleanup old deployments
    deploy.cleanup

    # send deployment notification, except for the default
  end
  
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
 
  task :stop, :roles => :app do
    # Do nothing.
  end
 
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

namespace :sphinx do
  
  desc 'Symlinks your custom directories'
  task :symlink, :roles => :app do
    run "ln -s #{shared_path}/db/sphinx #{latest_release}/db/sphinx"
    run "ln -s #{shared_path}/config/production.sphinx.conf #{latest_release}/config"
  end
  
  desc 'Stop sphinx server'  
  task :stop, :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:stop RAILS_ENV=#{rails_env}"
  end

  desc 'Start sphinx server'  
  task :start, :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=#{rails_env} && rake thinking_sphinx:start RAILS_ENV=#{rails_env}"
  end

  desc 'Restart sphinx server'
  task :restart, :roles => :app do
    sphinx.stop
    sphinx.start
  end
end
