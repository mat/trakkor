class CreateScrapeResults < ActiveRecord::Migration
  def self.up
    create_table :scrape_results do |t|

      t.timestamps
      t.integer :watch_id
      t.text  :text_raw
    end
  end

  def self.down
    drop_table :scrape_results
  end
end
