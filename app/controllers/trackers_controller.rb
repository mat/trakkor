require 'rubygems'
require 'hpricot'
require 'hpricot/inspect-html'
require 'cache'

class TrackersController < ApplicationController

  caches_page :index, :examples, :show

  # GET /trackers
  # GET /trackers.xml
  def index
    @trackers = Tracker.live_examples

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
    #@tracker = Tracker.find(params[:id])
    @tracker = Tracker.find_by_md5sum(params[:id])
    @changes = @tracker.changes

    if(params[:errors] == 'show')
      @changes += @tracker.error_pieces
      @changes = @changes.sort{ |a,b|  -(a.created_at <=> b.created_at) }
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tracker }
      format.microsummary { render :text => "Trakkor: #{@tracker.last_change.text}" } 
      format.atom
    end
  end

  # GET /trackers/new
  # GET /trackers/new.xml
  def new
    @tracker = Tracker.new(params[:tracker])
    #@tracker = Tracker.new
    #@tracker.uri = params[:uri]
    #@tracker.xpath = params[:xpath]
    #@tracker.name = params[:name]
    #@tracker.web_hook = params[:web_hook]
    
    
    if @tracker.uri && @tracker.xpath 
       @piece = @tracker.fetch_piece

       if @tracker.name.nil? || @tracker.name.empty?
         html_title = @tracker.html_title
         html_title = "#{html_title[0..50]}..." if html_title.length > 50
         @tracker.name = "Tracking '#{html_title}'"
       end
    end

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

  def testxpath
    @uri = params[:uri]
    @xpath = params[:xpath]

    raise "this is not an http uri: #{@uri}" unless Tracker.uri?(@uri)

    begin
      data, doc = cache.get(@uri), cache.get("#{@uri}.doc")
      if data and doc
        doc = Marshal.restore(doc)
        @complete_html = cache.get("#{@uri}.pretty_html")
      else
        data = Piece.fetch_from_uri(@uri).body
        doc = Hpricot.parse(data)
        @complete_html = PP.pp(doc.root, "")
        @complete_html.gsub!(/#XPATH#(.*)#\/XPATH#/, "/moduri/test?uri=#{@uri}&xpath=#{"\\1"}")

        cache.set(@uri, data)
	cache.set("#{@uri}.doc", Marshal.dump(doc))
	cache.set("#{@uri}.pretty_html", @complete_html)
      end

      @foo = "/test?uri=#{@uri}&xpath=#{@xpath}"

      html, text = Tracker.extract(doc, @xpath)
      if html and text
        flash[:notice] = "DOM elem found in uri, #{42} matches" 
    	@domnode_html = html
        @domnode_text = text
        @found_in_line = 4711
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

  def find_xpath
    @hits = flash[:hint] = flash[:error] = nil
    @uri    = params[:uri]
    @q = params[:q]

    if @uri.nil? || @q.nil? || @uri.empty? || @q.empty?
      flash[:hint] = "Please provide an URI and a search term."
      return 
    end

    begin
      doc = fetch_doc_from(@uri)
      @hits = Tracker.find_nodes_by_text(doc, @q) if doc

    rescue Exception => e
       flash[:error] = "Error: #{e.to_s}"
    end
 
  end


  def fetch_doc_from(uri)

    unless Tracker.uri?(@uri) then
      flash[:error] = "Please provide a proper HTTP URI like http://w3c.org"
      return nil
    end

    begin
      response, data = Piece.fetch_from_uri(@uri)

      unless response.kind_of? Net::HTTPSuccess
        flash[:error] = "Could not fetch the document, " +
           "server returned: #{response.code} #{response.message}"
        return nil
      end

      unless response.content_type =~ /text/
        flash[:hint] = "URI does not point to a text document " + 
                       "but a #{response.content_type} file."
      end

      doc = Hpricot(data)

      unless doc
        flash[:error] = 'URI does not point to a document that Trakkor understands.'        
        return nil
      end

    rescue Exception => e
       flash[:error] = "Error: #{e.to_s}"
       return nil
    end

    doc
  end

  def test_xpath
    @uri = params[:uri]
    @xpath = params[:xpath]
    
    if @uri.nil? || @xpath.nil? || @uri.empty? || @xpath.empty?
      flash[:hint] = "Please provide an URI and an XPath."
      return 
    end
      
     doc = fetch_doc_from(@uri)
     @elem, @parents = Piece.extract_with_parents(doc, @xpath) if doc
  end

  def stats
    @active_trackers = Tracker.find(:all).length
    @sick_trackers = Tracker.find(:all).find_all{ |t| t.sick? }
    @healthy_trackers = Tracker.find(:all).find_all{ |t| !t.sick? }
    @hook_trackers = Tracker.find(:all).find_all{ |t| t.web_hook }
    @newest_trackers = Tracker.newest_trackers
  end

  # GET /trackers/1/edit
  def edit
    @tracker = Tracker.find_by_md5sum(params[:id])
  end

  # POST /trackers
  # POST /trackers.xml
  def create
    @tracker = Tracker.new(params[:tracker])

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
    @tracker = Tracker.find_by_md5sum(params[:id])

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
    @tracker = Tracker.find_by_md5sum(params[:id])
    @tracker.destroy

    flash[:notice] = 'Tracker was deleted.'
    respond_to do |format|
      format.html { redirect_to(trackers_url) }
      format.xml  { head :ok }
    end
  end

  private

  def cache
    FileCache.new('tmp/tracker_test_cache')
  end
end
