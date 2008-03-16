class RenameWatchId < ActiveRecord::Migration
  def self.up
    rename_column(:scrape_results, :watch_id, :tracker_id)
  end

  def self.down
    rename_column(:scrape_results, :tracker_id, :watch_id)
  end
end
