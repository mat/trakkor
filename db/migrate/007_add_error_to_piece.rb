class AddErrorToPiece < ActiveRecord::Migration
  def self.up
    add_column :pieces, :error, :string
  end

  def self.down
    remove_columnd :pieces, :error
  end
end
