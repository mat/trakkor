require 'rubygems'
require 'hpricot'

class Piece < ActiveRecord::Base

  # das piece in chunk umbennenen?
  belongs_to :tracker

  def fetch(uri,xpath)
    start = Time.now.to_f
    begin
      response = Piece.fetch_from_uri(uri)
    rescue Exception => e
      self.error = "Error: #{e.to_s}"
    end

    duration = Time.now.to_f - start

    if response.kind_of? Net::HTTPSuccess
      html, self.text, self.error = Piece.extract_piece(response.body, xpath)
      self.bytecount = response.body.length if response.body
    else
      self.error = "Error: #{response.code} #{response.message}"
    end
    
    self
  end

  def Piece.create(source)
    p = Piece.new

    if Hpricot::Elem === source then
      p.text = source.inner_text
    end

    p
  end


  def Piece.fetch_from_uri(uri)
    parsed_uri = URI.parse(URI.escape(uri))
    response = Net::HTTP.get_response(parsed_uri)
  end

  def Piece.extract_piece(data, xpath)

    begin
      html, text = Piece.extract_text(data, xpath)
      raise "No DOM node found for given XPath." if html.nil?
    rescue Exception => e
      return [nil, nil, e.to_s]
    end
 
    [html, text, nil]
  end


  def Piece.extract_elem(data,xpath)
    if Hpricot::Doc === data
      doc = data
    else
      doc = Hpricot.parse(data.to_s)
    end

    elem = doc.at(xpath)
  end

  def Piece.extract_text(data, xpath)
    elem = Piece.extract_elem(data, xpath)
    return nil unless elem
    [elem.to_original_html, elem.inner_text]
  end


  def Piece.extract_with_parents(doc, xpath)
    piece = e = doc.at(xpath)
    parents = []
    while e.parent.class != Hpricot::Doc do
      parents << e.parent
      e = e.parent
    end
    [piece,parents[0..2]]
  end

  def Piece.fetch_title(uri)
    p = Piece.new.fetch(uri, '//head/title/text()')
    return nil if p.error
    p.text
  end

  def before_save
    self.text = Piece.tidy_text(self.text) if self.text
  end

  def same_content(other)
     return false if other.nil?
 
     self.text == other.text
  end


  def Piece.html_to_text(html)
    Hpricot(html).inner_text
  end


  def Piece.tidy_text(str)
   str = tidy_tabby_lines(str)
   str = tidy_multiple_nl(str)
   str = str.strip
  end

  private
  def Piece.tidy_tabby_lines(str)
    str.gsub(/\n\t+\n/, "\n\n")
  end

  def Piece.tidy_multiple_nl(str)
    str.gsub(/\n\n+/, "\n")
  end
end
