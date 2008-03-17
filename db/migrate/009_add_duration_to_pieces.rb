class AddDurationToPieces < ActiveRecord::Migration
  def self.up
     add_column :pieces, :duration, :float
  end

  def self.down
    remove_column :pieces, :duration
  end
end
