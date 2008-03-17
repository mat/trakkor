require 'yaml'
require 'logger'
   
require "rubygems"
require "activerecord"

SCRAPER_PATH = ENV['SCRAPER_PATH']

raise 'Env variable SCRAPER_PATH not set.'if SCRAPER_PATH.nil?

require "#{SCRAPER_PATH}/app/models/tracker.rb"
require "#{SCRAPER_PATH}/app/models/piece.rb"

LOGFILE = "#{ENV['SCRAPER_PATH']}/log/scrape-n-save.log"
DATABASE = "#{ENV['SCRAPER_PATH']}/db/dev.sqlite3"

#dbconfig = YAML::load(File.open('/home/mat/svn_workspaces/ruby/scraper/rails/config/database.yml'))  
#ActiveRecord::Base.establish_connection(dbconfig)  

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => DATABASE)

ActiveRecord::Base.colorize_logging = false
ActiveRecord::Base.logger = Logger.new(STDERR)  
ActiveRecord::Base.logger = Logger.new(File.open(LOGFILE, 'a'))


trackers = Tracker::find(:all)

trackers.each do |tracker|
 tracker.fetch_piece.save!
end
