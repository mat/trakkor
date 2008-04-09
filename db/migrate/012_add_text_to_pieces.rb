class AddTextToPieces < ActiveRecord::Migration
  def self.up
    add_column :pieces, :text, :text
    convert_html_to_text
  end

  def self.down
    remove_column :pieces, :text
  end

  private
  def self.convert_html_to_text
    Piece.find(:all).each do |p| 
      if p.text_raw
        p.text = Piece.html_to_text(p.text_raw)
      else
        p.text = nil
      end
      p.save!
    end
  end
end
