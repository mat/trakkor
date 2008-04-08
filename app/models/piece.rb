require 'rubygems'
require 'hpricot'

class Piece < ActiveRecord::Base

  # das piece in chunk umbennenen?
  # # 
  belongs_to :tracker

  def same_content(other)
     return false if other.nil?
 
     self.text_raw == other.text_raw
  end


  def Piece.html_to_text(html)
    Hpricot(html).inner_text
  end
end
