require 'digest/md5'
require 'net/http'
require 'xml/libxml'

# Don't let errors go to stderr, collect them.
msgs = []
XML::Parser.register_error_handler lambda { |msg| msgs << msg }
XML::Parser::default_line_numbers=true

raise 'Ancient libxml-ruby bindings found, need >=0.5.2' unless defined? XML::HTMLParser

class Tracker < ActiveRecord::Base
  validates_presence_of :uri, :xpath

  validates_format_of :uri, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix

  has_many :pieces, :order => 'created_at DESC'

  def validate_on_create # is only run the first time a new object is save
    @first_piece = fetch_piece
    if @first_piece.error
       errors.add("URI and XPath", "yield no content")
    end
  end

  after_save :fetch_n_save_first_piece

  def fetch_n_save_first_piece
    @first_piece.save!
  end

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

  def pieces_with_error
  end

  def last_update
    #return 'now update recognized' if pieces_dupefree.empty?
    pieces_dupefree.first.created_at
  end

  def last_piece
    #return 'now pieces recorded' if pieces.empty?
    pieces.first.created_at
  end

  def bytes_recorded
     sql = "SELECT SUM(bytecount) FROM pieces WHERE tracker_id=#{self.id}"
     ActiveRecord::Base.connection.select_one(sql).to_a.first.last.to_i
  end

  def extract_piece(data, xpath)

  begin
    doc  = XML::HTMLParser.string(data).parse
    node = doc.find(xpath)
    raise "No DOM node found for given XPath." if node.set.first.nil?
  rescue Exception => e
    return [nil, e.to_s]
  end

  text = node.set.first.to_s

  return [text, nil]
end

  def html_title
    fetch_piece unless @body 
    extract_piece(@body, '//head/title/text()').first
  end

  def fetch_piece
    p = Piece.new
    p.tracker = self

    parsed_uri = URI.parse(self.uri)

    start = Time.now.to_f
    response = Net::HTTP.get_response(parsed_uri)
    p.duration = Time.now.to_f - start
    p.bytecount = response.body.length if response.body

    if response.kind_of? Net::HTTPSuccess
      p.text_raw, p.error = extract_piece(response.body, self.xpath)
      @body = response.body
    else
      p.error = "Error: #{response.code} #{response.message}"
      @body = nil
    end
    

    p

  end
end
