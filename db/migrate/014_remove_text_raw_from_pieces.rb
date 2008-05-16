class RemoveTextRawFromPieces < ActiveRecord::Migration
  def self.up
    remove_column :pieces, :text_raw
  end

  def self.down
    add_column :pieces, :text_raw, :text
 end
end
