set :application, "trakkor"
set :deploy_to, "/home/mat/www/#{application}"
set :use_sudo, false

set :scm, :git
set :repository, "git://github.com/mat/trakkor.git"
set :branch, "master"

server "better-idea.org", :app, :web, :db, :primary => true

depend :remote, :file, "#{shared_path}/config/config.yml"
depend :remote, :file, "#{shared_path}/db/production.sqlite3"

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


#namespace :cache do
#  desc "rake cache:sweep"
#  task :sweep do
#    run "cd #{current_path} && rake cache:sweep"
#  end
#end

#after :deploy, "cache:sweep"

