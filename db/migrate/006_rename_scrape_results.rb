class RenameScrapeResults < ActiveRecord::Migration
  def self.up
    rename_table("scrape_results", "pieces")
  end

  def self.down
    rename_table("pieces", "scrape_results")
  end
end
