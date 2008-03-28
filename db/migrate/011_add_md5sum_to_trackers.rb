class AddMd5sumToTrackers < ActiveRecord::Migration
  def self.up
    add_column :trackers, :md5sum, :string
  end

  def self.down
    remove_column :trackers, :md5sum
  end
end
