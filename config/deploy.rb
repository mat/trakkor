set :application, "mendono"
set :repository,  "svn://cjs3f.de:4712/ruby/scraper/rails"
set :runner,  "mat"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "better-idea.org"
role :web, "better-idea.org"
role :db, "better-idea.org", :primary => true
