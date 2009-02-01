namespace :db do

  desc "Remove pieces older than 6 months from db."
  task :remove_old_pieces => :environment do
    Piece.delete_old_pieces
  end

  desc "Remove redundant pieces from db."
  task :remove_redundant_pieces => :environment do
    Tracker.remove_all_redundant_pieces
  end

  desc "Vacuum the sqlite3 database."
  task :vacuum => :environment do
    ActiveRecord::Base.connection.execute('VACUUM;')
  end
  
  desc "Tidy the database."
  task :tidy => [:remove_old_pieces, :remove_redundant_pieces, :vacuum] do
    #nothing
  end
end

