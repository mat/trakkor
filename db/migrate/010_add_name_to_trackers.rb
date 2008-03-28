class AddNameToTrackers < ActiveRecord::Migration
  def self.up
    add_column :trackers, :name, :string
  end

  def self.down
    remove_column :trackers, :name
  end
end
