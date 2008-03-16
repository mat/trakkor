require 'digest/md5'

class Tracker < ActiveRecord::Base
  validates_presence_of :uri, :xpath

  validates_format_of :uri, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix

  has_many :pieces, :order => 'created_at DESC'

  def md5sum
    payload = uri + xpath + created_at.to_s
    Digest::MD5.hexdigest(payload)
  end

  def pieces_dupefree()
    all_changes = pieces.reverse
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

  def last_update
    return 'now update recognized' if pieces_dupefree.empty?
    pieces_dupefree.first.created_at
  end

  def last_piece
    return 'now pieces recorded' if pieces.empty?
    pieces.first.created_at
  end
end
