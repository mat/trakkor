class AddWebHookToTrackers < ActiveRecord::Migration
  def self.up
     add_column :trackers, :web_hook, :text
  end

  def self.down
    remove_column :trackers, :web_hook
  end
end
