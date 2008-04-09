require 'digest/md5'
require 'net/http'
require 'hpricot'

class Tracker < ActiveRecord::Base
  R_URI = /^(http|https):\/\/.*?$/ix


  validates_presence_of :uri, :xpath
  validates_format_of :uri, :with =>  R_URI
  validates_uniqueness_of :md5sum

  # order: oldest piece first, most recent last
  has_many :pieces, :order => 'created_at ASC' 

  def before_create 
    generate_md5_key
    set_name
  end

  def generate_md5_key
    @attributes['md5sum'] = Digest::MD5.hexdigest((object_id + rand(255)).to_s)
  end

  def validate_on_create # is only run the first time a new object is save
    @first_piece = fetch_piece
    if @first_piece.error
       errors.add("URI and XPath", "yield no content")
    end
  end

  def set_name
    self.name ||= "Tracker for #{html_title || uri}"
  end

  def before_update
    set_name
  end

  def Tracker.uri?(str)
    str =~ R_URI
  end

  def after_create
    fetch_piece.save!
  end

  def pieces_errorfree
    pieces.find( :all, :conditions => { :error => nil}, :order => 'created_at ASC' )
  end

  def error_pieces
    pieces.find( :all, :conditions => 'NOT error IS NULL', :order => 'created_at ASC' )
   # pieces.find( :all, :conditions => { :error => nil}, :order => 'created_at ASC' )
  end

  def changes
    all_changes = pieces_errorfree
    dupefree_changes = []

   prev_change = nil
   all_changes.each do |c|

      unless c.same_content(prev_change) then
 	dupefree_changes << c
      end
     
     prev_change = c
   end

   # return most recent change first and on top
   dupefree_changes.reverse
  end

  def last_change
    #return 'now update recognized' if changes.empty?
    changes.first
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
   html, text = Tracker.extract(data, xpath)
   # doc  = XML::HTMLParser.string(data).parse
   # node = doc.find(xpath)
    raise "No DOM node found for given XPath." if html.nil?
  rescue Exception => e
    return [nil, nil, e.to_s]
  end

  [html, text, nil]
end

  def html_title
    fetch_piece unless @body 
    _, title_as_text, _ = extract_piece(@body, '//head/title/text()')
    title_as_text
  end

  def fetch_piece
    p = Piece.new
    p.tracker = self

    start = Time.now.to_f
    response = Tracker.fetch(self.uri)
    p.duration = Time.now.to_f - start
    p.bytecount = response.body.length if response.body

    if response.kind_of? Net::HTTPSuccess
      p.text_raw, p.text, p.error = extract_piece(response.body, self.xpath)
      @body = response.body
    else
      p.error = "Error: #{response.code} #{response.message}"
      @body = nil
    end
    
    p
  end

  def Tracker.extract(data, xpath)
    if Hpricot::Doc === data
      doc = data
    else
      doc = Hpricot.parse(data.to_s)
    end

    piece = doc.at(xpath)

    return nil unless piece
    [piece.to_original_html, piece.inner_text]
  end

  def Tracker.replace_id_funtion(xpath)
    xpath.gsub(/^id\((.*?)\)/x,"//[@id=\\1]")
  end

  def Tracker.fetch(uri)
    parsed_uri = URI.parse(URI.escape(uri))
    response = Net::HTTP.get_response(parsed_uri)
  end

  
end
