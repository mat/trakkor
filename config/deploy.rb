set :application, "trakkor"
set :deploy_to, "/home/mat/www/#{application}"
set :use_sudo, false

set :scm, :git
set :repository, "git://github.com/mat/trakkor.git"
set :branch, "master"

server "better-idea.org", :app, :web, :db, :primary => true

depend :remote, :file, "#{shared_path}/config/config.yml"
depend :remote, :file, "#{shared_path}/config/thin.yml"
depend :remote, :file, "#{shared_path}/db/production.sqlite3"
depend :remote, :directory, "/var/tmp/trakkor/cache/rack/meta"
depend :remote, :directory, "/var/tmp/trakkor/cache/rack/body"

desc "A setup task to put shared system, log, and database directories in place"
task :setup, :roles => [:app, :db, :web] do
run <<-CMD
mkdir -p -m 775 #{release_path} #{shared_path}/system #{shared_path}/db #{shared_path}/config &&
mkdir -p -m 777 #{shared_path}/log
CMD
end

after "deploy:symlink", :symlink_shared

task :symlink_shared do
  run("ln -s #{shared_path}/config/config.yml #{current_path}/config/config.yml")
end


namespace :deploy do
  %w(start stop restart).each do |action|
    desc "#{action} our server"
    task action.to_sym do
      find_and_execute_task("thin:#{action}")
    end
  end
end


namespace :thin do
  desc "Generate a thin configuration file"
  task :build_configuration, :roles => :app do
    config_options = {
        "log" => "#{shared_path}/log/thin.log",
        "chdir" => current_path,
        "port" => 3600,
        "servers" => 1,
        "environment" => "production",
        "address" => "localhost",
        "pid" => "#{shared_path}/pids/thin.pid"
    }.to_yaml
    put config_options, "#{shared_path}/config/thin.yml"
  end

  %w(start stop restart).each do |action|
    desc "#{action} this app's Thin Cluster"
    task action.to_sym, :roles => :app do
      run "thin #{action} -C #{shared_path}/config/thin.yml"
    end
  end
end

