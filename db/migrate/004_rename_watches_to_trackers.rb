class RenameWatchesToTrackers < ActiveRecord::Migration
  def self.up
    rename_table('watches', 'trackers')
  end

  def self.down
    rename_table('trackers', 'watches')
  end
end
