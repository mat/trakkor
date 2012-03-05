class AddSomeIndexesToPieces < ActiveRecord::Migration
  def self.up
    add_index :pieces, [:tracker_id, :error]
    add_index :pieces, [:tracker_id, :created_at]
    add_index :trackers, [:md5sum]
  end

  def self.down
  end
end
