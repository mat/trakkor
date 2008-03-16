require 'digest/md5'
require 'net/http'
require 'xml/libxml'

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
    #return 'now update recognized' if pieces_dupefree.empty?
    pieces_dupefree.first.created_at
  end

  def last_piece
    #return 'now pieces recorded' if pieces.empty?
    pieces.first.created_at
  end

def print_dom_elem_from_data(data, xpath)
# Don't let errors go to stderr, collect them.
msgs = []
XML::Parser.register_error_handler lambda { |msg| msgs << msg }
XML::Parser::default_line_numbers=true

  doc  = XML::HTMLParser.string(data).parse
  node = doc.find(xpath)
  raise "no node found" unless node or node.length == 0
  raise "cannot retrieve domnode content" if node.set.first.nil?

  html_source = node.set.first.to_s

return html_source
end

  def fetch_piece
    p = Piece.new
    p.tracker = self

    response = Net::HTTP.get_response(URI.parse(self.uri))
    if response.kind_of? Net::HTTPSuccess
      p.text_raw = print_dom_elem_from_data(response.body, self.xpath)
    else
      p.error = "Error: #{response.code} #{response.message}"
    end

    p

  end
end
