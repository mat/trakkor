class RenameDomnodeToXpath < ActiveRecord::Migration
  def self.up
     rename_column :watches, :domnode, :xpath
  end

  def self.down
     rename_column :watches, :xpath, :domnode
  end
end
