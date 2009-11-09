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
role :db,  domain

namespace :deploy do
  # task :start {}
  # task :stop {}
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end