namespace :db do

  desc "Remove redundant pieces from db."
  task :remove_redundant_pieces => :environment do
    Tracker.remove_all_redundant_pieces
  end

  desc "Vacuum the sqlite3 database."
  task :vacuum => :environment do
    ActiveRecord::Base.connection.execute('VACUUM;')
  end

  
  desc "Tidy the database."
  task :tidy => [:remove_redundant_pieces, :vacuum] do
    #nothing
  end
end

