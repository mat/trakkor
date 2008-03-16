class AddByteCountToPiece < ActiveRecord::Migration
  def self.up
    add_column :pieces, :bytecount, :integer
  end

  def self.down
    remove_column :pieces, :bytecount
  end
end
