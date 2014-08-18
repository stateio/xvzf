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
set :branch, ENV['BRANCH'] || 'master'

set :deploy_to, "/var/www/#{fetch(:application)}"
set :user, "xvzf"
role :web, "okayfail.com"

namespace :deploy do
  task :bundle do
    run "cd #{current_path} && bundle install"
  end
  task :run_middleman do
    run "cd #{current_path} && bundle exec middleman build"
  end

 desc "Linking application specific directories"
  task :create_symlinks do
    run "ln -nfs #{shared_path}/ohhi/ #{release_path}/_site/ohhi"
    run "ln -nfs #{release_path}/_site/ohhi #{release_path}/_site/public"
    
    run "ln -nfs #{release_path}/_site/podcast/ #{release_path}/_podcast"
    run "ln -nfs #{shared_path}/mp3/ #{release_path}/_podcast/mp3"
    run "ln -nfs #{shared_path}/webalizer/ #{release_path}/_site/_webalizer"
  end

end

task :podcast do
  podcast_file = File.join(File.dirname(__FILE__), "../_podcast/podcast.atom")
  temp_file = "/tmp/xvzf-podcast-temp.atom"
  File.open(temp_file, 'w') do |file|
    run "#{current_path}/podcast/mkreal" do |channel, stream, data|
      file.puts data
      puts data
    end
  end
  File.rename(temp_file, podcast_file)
  puts
  puts "Podcast saved to _podcast/podcast.atom"
end

after "deploy:restart", "deploy:run_middleman"
after "deploy:run_middleman", "deploy:create_symlinks"
