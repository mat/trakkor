require 'digest/md5'

class Tracker < ActiveRecord::Base
  validates_presence_of :uri, :xpath
  has_many :scrape_results, :order => 'created_at DESC'

  def md5sum
    payload = uri + xpath + created_at.to_s
    Digest::MD5.hexdigest(payload)
  end

  def scrape_results_dupefree()
    all_changes = scrape_results.reverse
    dupefree_changes = []

   prev_change = nil
   all_changes.each do |c|

      unless c.same_content(prev_change) then
 	dupefree_changes << c
      end
     
     prev_change = c
   end

   dupefree_changes.reverse
  end
end
