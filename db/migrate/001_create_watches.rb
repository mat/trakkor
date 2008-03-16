class CreateWatches < ActiveRecord::Migration
  def self.up
    create_table :watches do |t|

      t.timestamps
      t.string :uri
      t.string :domnode
    end
  end

  def self.down
    drop_table :watches
  end
end
