# Capistrano configuration for internal deployment
#
# Expects target server to run Nginx + Phusion Passenger 3. Uses a system-wide
# RVM installation and Bundler to auto-update dependencies. Please manually
# create a '1.9.2@warble' gemset with the bundler gem already installed
# before first deployment. Also put the host's redis configuration at
# /usr/local/srv/warble/config/redis.yml. Create a ruby wrapper script
# at /usr/local/srv/warble/shared/bin/ruby that sets the facebook API
# environment variables. Set passenger to use that as its ruby.
# Node server isn't handled by these tasks currently.
#
# For more information on Capistrano, see
#   https://github.com/capistrano/capistrano/wiki
#

require 'bundler/capistrano'

set :application, 'warble'

# repository options
set :scm,        :git
set :repository, 'https://github.com/nixme/warble.git'
set :branch,     'master'
set :deploy_via, :remote_cache

# server options
server 'warble', :web, :app, :db, :primary => true
set :user,            'gopal.patel'
set :deploy_to,       "/usr/local/srv/#{application}"
set :keep_releases,   5
default_run_options[:pty] = true

set :default_environment, {
  'PATH' => '/usr/local/ruby-1.9.3-p0/bin:$PATH'
}

namespace :deploy do
  # passenger is always running, so start and stop are no-ops
  task :start  do ; end
  task :stop   do ; end

  # we don't use activerecord or a relational db, so migrations are no-op
  task :migrate     do ; end
  task :migrations  do ; end

  desc 'Restarts your application'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  desc 'Package and upload front-end assets'
  task :upload_assets, :roles => :app, :except => { :no_release => true } do
    run_locally 'bundle exec rake assets:precompile'

    top.upload File.join('public', 'assets'),
               File.join(release_path, 'public', 'assets')
  end

  desc 'Update symlinks for configuration files and directories'
  task :symlink_config, :roles => :app, :except => { :no_release => true } do
    # datastore configurations
    run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
    run "ln -nfs #{shared_path}/config/sunspot.yml #{release_path}/config/sunspot.yml"

    # archived songs directory
    run "rm #{release_path}/public/songs/.gitkeep && rmdir #{release_path}/public/songs"
    run "ln -nfs #{shared_path}/songs #{release_path}/public/songs"
  end

  desc 'Symlink Resque admin assets directory'
  task :symlink_resque_assets, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; ln -nfs `bundle show resque`/lib/resque/server/public public/resque"
  end

  desc 'Refresh connected clients'
  task :refresh_clients, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; rake clients:refresh RAILS_ENV=production"
  end

  after 'deploy:finalize_update', 'deploy:symlink_config'
  after 'deploy:update_code',     'deploy:upload_assets'
  after 'deploy:update_code',     'deploy:symlink_resque_assets'
  after 'deploy:restart',         'deploy:refresh_clients'
end
