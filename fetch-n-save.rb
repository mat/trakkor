require 'yaml'
require 'logger'
   
require "rubygems"
require "activerecord"

SCRAPER_PATH = ENV['SCRAPER_PATH']

raise 'Env variable SCRAPER_PATH not set.'if SCRAPER_PATH.nil?
raise "SCRAPER_PATH (#{SCRAPER_PATH}) does not exist." unless File.exist? SCRAPER_PATH

require "#{SCRAPER_PATH}/app/models/tracker.rb"
require "#{SCRAPER_PATH}/app/models/piece.rb"

LOGFILE = "#{ENV['SCRAPER_PATH']}/log/scrape-n-save.log"
DATABASE = "#{ENV['SCRAPER_PATH']}/db/development.sqlite3"

#dbconfig = YAML::load(File.open('/home/mat/svn_workspaces/ruby/scraper/rails/config/database.yml'))  
#ActiveRecord::Base.establish_connection(dbconfig)  

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => DATABASE)

ActiveRecord::Base.colorize_logging = false
ActiveRecord::Base.logger = Logger.new(STDERR)  
ActiveRecord::Base.logger = Logger.new(File.open(LOGFILE, 'a'))


trackers = Tracker::find(:all)

must_notify = []

trackers.each do |tracker|

 print "Fetching #{tracker.uri}... " ; STDOUT.flush
 old_piece = tracker.current
 new_piece = tracker.fetch_piece
 new_piece.save!
 puts "ok."

 if tracker.should_notify?(old_piece,new_piece)
   must_notify << [tracker, old_piece, new_piece]
 end
end

must_notify.each{ |t, old, new| 
  t.notify_change(old, new)
}
