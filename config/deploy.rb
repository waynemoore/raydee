set :application, "raydee"
set :repository,  "git@github.com:waynemoore/raydee.git"

set :scm, :git

server 'aztec.local', :app, :web, :db
# server 'localhost', :app, :web, :db, :port => 9022

set :deploy_to, "~/raydee"
set :rvm_ruby_string, '1.9.3'

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do

  task :start do
    run "cd #{current_path} && nohup script/start", :pty => true
  end

  task :stop do
    run "kill `pidof bundle exec ruby raydee.rb` | true"
  end

  task :restart do
    find_and_execute_task("deploy:stop")
    find_and_execute_task("deploy:start")
  end

end

namespace :puppet do

  task :prepare do
    sudo "dpkg -s puppet || sudo apt-get -y install puppet"
  end

  task :apply do
    upload "config/raydee.pp", "/tmp/raydee.pp"
    sudo "puppet apply /tmp/raydee.pp"
  end

end

namespace :raydee do

  namespace :daemon do

    task :start do
      run "cd #{current_path} && bundle exec ruby daemon.rb start"
    end

    task :stop do
      run "cd #{current_path} && bundle exec ruby daemon.rb stop"
    end

    task :restart do
      run "cd #{current_path} && bundle exec ruby daemon.rb start"
    end

  end

end

# after "deploy:restart", "raydee:daemon:restart"

