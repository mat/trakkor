require 'rubygems'
require 'xml/libxml'

XML::Parser::default_line_numbers=true



module XML
  class Node
    def traverse(&block)
      raise "ooops, got #{self.class}" unless self.class == XML::Node
      yield self
      self.to_a.each{ |child| child.traverse(&block) }
    end

    def id_path
      return "id('#{self['id']}')" if self['id']
     
      id_parent = nearest_parent_with_id
      if id_parent
        self.path.sub(id_parent.path, "id('#{id_parent['id']}')")
      else
        self.path
      end
    end

    def nearest_parent_with_id
      return nil if parent.class == XML::Document
      return parent if parent['id']       

      parent.nearest_parent_with_id
    end

  end
end



class TrackersController < ApplicationController

  caches_page :index, :examples, :show

  # GET /trackers
  # GET /trackers.xml
  def index
    @trackers = [Tracker.find(3)] + [Tracker.find(1] + [Tracker.find(2)]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trackers }
    end
  end

  def examples
    @trackers = Tracker.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /trackers/1
  # GET /trackers/1.xml
  def show
    @tracker = Tracker.find(params[:id])
    #@tracker = Tracker.find_by_md5sum(params[:md5sum])
    @changes = @tracker.changes

    if(params[:errors] == 'show')
      @changes += @tracker.error_pieces
      @changes = @changes.sort{ |a,b|  -(a.created_at <=> b.created_at) }
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tracker }
      format.atom
    end
  end

  # GET /trackers/new
  # GET /trackers/new.xml
  def new
    @tracker = Tracker.new
    @tracker.uri = params[:uri]
    @tracker.xpath = params[:xpath]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tracker }
    end
  end

  def ajax_get_piece
    uri = params[:uri]
    xpath = params[:xpath]
    render :text => "hossa we got #{uri}<br> and #{xpath}"
  end

  def test
    @uri = params[:uri]
    @xpath = params[:xpath]

    raise "this is not an http uri: #{@uri}" unless Tracker.uri?(@uri)

    begin
      parsed_uri = URI.parse(@uri)
      response = Net::HTTP.get_response(parsed_uri)
      data = response.body
      @complete_html = html(data)
      @complete_html.gsub!(/##XPATH##(.*)##\/XPATH##/, "/moduri/test?uri=#{@uri}&xpath=#{"\\1"}")
      @foo = "/test?uri=#{@uri}&xpath=#{@xpath}"
      libxmldoc  = XML::HTMLParser.string(data).parse
      libxml_fragment = libxmldoc.find(@xpath)

      if libxml_fragment and libxml_fragment.length > 0
        flash[:notice] = "DOM elem found in uri, #{libxml_fragment.set.length} matches" 
    	@domnode_html = libxml_fragment.set.first.to_s
	@domnode_text = libxml_fragment.set.first.content
        @found_in_line = libxml_fragment.set.first.line_num
      else
        flash[:notice] = 'Cannot find DOM elem designated by given xpath.'
    	@domnode_html = 'nix'
	@domnode_text = 'nix'
      end

    rescue Exception => e
       flash[:notice] = "Error: #{e.to_s}"
       flash[:hint] = "Hint: #{e.to_s}"
    end


    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => nil }
    end
  end

  def stats
    @active_trackers = Tracker.find(:all).length
  end

  # GET /trackers/1/edit
  def edit
    @tracker = Tracker.find(params[:id])
  end

  # POST /trackers
  # POST /trackers.xml
  def create
    @tracker = Tracker.new(params[:tracker])

    #unless @tracker.uri =~ Tracker::R_URI

    respond_to do |format|
      if @tracker.save
        flash[:notice] = 'Tracker was successfully created.'
        format.html { redirect_to(@tracker) }
        format.xml  { render :xml => @tracker, :status => :created, :location => @tracker }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tracker.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trackers/1
  # PUT /trackers/1.xml
  def update
    @tracker = Tracker.find(params[:id])

    respond_to do |format|
      if @tracker.update_attributes(params[:tracker])
        flash[:notice] = 'Tracker was successfully updated.'
        format.html { redirect_to(@tracker) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tracker.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trackers/1
  # DELETE /trackers/1.xml
  def destroy
    @tracker = Tracker.find(params[:id])
    @tracker.destroy

    flash[:notice] = 'Tracker was deleted.'
    respond_to do |format|
      format.html { redirect_to(trackers_url) }
      format.xml  { head :ok }
    end
  end


	private

def wrap(str, indent='')
  return indent + str if str.length < 70

  lines = ''
  tokens = str.split(' ').reverse
  lin = indent.clone

  until tokens.empty?
   tok = tokens.pop

   if lin.length < 70 + indent.length
      lin << tok + " "
   else
    lines << lin + "\n"
    lin = indent + tok + " "
   end
  end

  lines << lin + "\n"

  lines
end

def html(data)
  doc  = XML::HTMLParser.string(data).parse
  out = ''
  html_impl(doc.root, out)

  out
end

HTML_ESCAPE = {'&'=>'&amp;', '"'=>'&quot;', '>'=>'&gt;', '<'=>'&lt;'}

def html_escape(s)
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
end

def html_impl(node, out, level=0)

  if %w( h1 h2 h3 h4 h5 h6 strong b i p li title ).include? node.name and node.to_a.length == 1 and node.to_a.first.name == 'text'
    out << "  " * level
    out << html_escape("<")
    out << "<a href=\"##XPATH###{node.id_path}##/XPATH##\">#{node.name}</a>"
    out << html_escape(">")
    out << html_escape(node.content)
    out << html_escape("</#{node.name}>")
    out << "\n"
    return
  end

  if node.to_a.empty? and !node.text?
    out << "  " * level
    out << html_escape(node.to_s)
  elsif node.name == 'text'
    out << wrap(node.to_s, "  " * level)
  else
    out << "  " * level 
    out << html_escape("<")
    out << "<a href=\"##XPATH###{node.id_path}##/XPATH##\">#{node.name}</a>"
    node.each_attr{ |a| out << " #{a.name}=\"#{a.value}\"" }
    out << html_escape(">")
    tag_open = true
  end
  out << "\n"
  node.to_a.each{ |c| html_impl(c, out, level+1) }

  if node.name != 'text' and tag_open
    out << html_escape("  " * level + "</#{node.name}>")
    out << "\n"
  end
end


end
