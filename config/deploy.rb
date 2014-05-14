require "bundler/capistrano"
require "rvm/capistrano"
set :rvm_ruby_string, 'ruby-1.9.3'
set :rvm_type, :user
set :application, "xvzf.io"
set :repository,  "git@github.com:stateio/xvzf.git"
set :use_sudo, false
set :scm, :git
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :user, "deploy"
role :web, "okayfail.com"

namespace :deploy do
  task :bundle do
    run "cd #{current_path} && bundle install"
  end
  task :run_jekyll do
    run "cd #{current_path} && bundle exec jekyll build"
  end

 desc "Linking application specific directories"
  task :create_symlinks, :roles => :app do
    run "ln -nfs #{shared_path}/ohhi/ #{release_path}/ohhi/"
  end

end

after "deploy:restart", "deploy:run_jekyll"
after "deploy:run_jekyll", "deploy:create_symlinks"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
