set :application, "papercups"
set :domain, "#{application}.superalloy.nl"
set :deploy_to, "/var/www/#{domain}"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :repository,  "git@github.com:alloy/paper-cups.git"
set :scm, "git"
set :branch, "master"
set :repository_cache, "git_cache"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

set :user, "deploy"

role :web, domain
role :app, domain
role :db,  domain, :primary => true

namespace :deploy do
  task :link_session_store do
    path = 'config/initializers/session_store.rb'
    run "ln -fs #{File.join(deploy_to, 'shared', path)} #{File.join(release_path, path)}"
  end
  
  task :link_attachments do
    path = 'public/attachments'
    run "ln -s #{File.join(deploy_to, 'shared', path)} #{File.join(release_path, path)}"
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:finalize_update", "deploy:link_session_store"
after "deploy:finalize_update", "deploy:link_attachments"