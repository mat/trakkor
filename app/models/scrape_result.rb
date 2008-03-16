class ScrapeResult < ActiveRecord::Base
  belongs_to :tracker

  def same_content(other)
     return false if other.nil?
 
     self.text_raw == other.text_raw
  end
end
