require 'rubygems'
require 'hpricot'

class Piece < ActiveRecord::Base

  # das piece in chunk umbennenen?
  # # 
  belongs_to :tracker

  def before_save
    self.text = Piece.tidy_text(self.text)
  end

  def same_content(other)
     return false if other.nil?
 
     self.text == other.text
  end


  def Piece.html_to_text(html)
    Hpricot(html).inner_text
  end


  def self.tidy_text(str)
   str = tidy_tabby_lines(str)
   str = tidy_multiple_nl(str)
   str = str.strip
  end

  private
  def self.tidy_tabby_lines(str)
    str.gsub(/\n\t+\n/, "\n\n")
  end

  def self.tidy_multiple_nl(str)
    str.gsub(/\n\n+/, "\n")
  end
end
