require 'rubygems'
require 'hpricot'
require 'hpricot/inspect-html'
require 'cache'

class TrackersController < ApplicationController
  protect_from_forgery :except => [:changes_and_errors]

  def index
    @trackers = Tracker.live_examples
  end

  def show
    expires_in 5.minutes, :private => false
    @tracker = Tracker.find_by_md5sum(params[:id])

    if stale?(:last_modified => @tracker.last_modified, :public => true)
      @changes = @tracker.changes

      if(params[:errors] == 'show')
        @changes += @tracker.sick?  # add 10 most recent errors
        @changes = @changes.sort{ |a,b|  -(a.created_at <=> b.created_at) }
      end

      respond_to do |format|
        format.html # show.html.erb
        format.microsummary { render :text => "Trakkor: #{@tracker.last_change.text}" }
        format.atom
      end
    end
  end

  def changes_and_errors
    @tracker = Tracker.find_by_md5sum(params[:id])
    unless @tracker
      render :text => "Tracker id missing or wrong."
    else
      @pieces = @tracker.changes

      if(@tracker.sick?)
        @pieces += @tracker.sick?  # add 10 most recent errors
        @pieces = @pieces.sort{ |a,b|  -(a.created_at <=> b.created_at) }
      end
      render :layout => false
    end
  end

  def new
    @tracker = Tracker.new(params[:tracker])
    
    if @tracker.uri && @tracker.xpath 
       @piece = @tracker.fetch_piece

       if @tracker.name.nil? || @tracker.name.empty?
         html_title = @tracker.html_title
         html_title = "#{html_title[0..50]}..." if html_title.length > 50
         @tracker.name = "Tracking '#{html_title}'"
       end
    end
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

  def web_hook
    #@active_trackers = Tracker.find(:all).length
  end

  def stats
    authenticate
    @active_trackers = Tracker.find(:all).length
    @sick_trackers = Tracker.find(:all).find_all{ |t| t.sick? }
    @healthy_trackers = Tracker.find(:all).find_all{ |t| !t.sick? }
    @hook_trackers = Tracker.web_hooked
    @newest_trackers = Tracker.newest
  end

  def create
    @tracker = Tracker.new(params[:tracker])

    if @tracker.save
      flash[:notice] = 'Tracker was successfully created.'
      redirect_to(@tracker)
    else
      render :action => "new"
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic("Trakkor stats") do |username, password|
      username == "admin" && password == APP_CONFIG['password']
    end
  end

  def cache
    FileCache.new('tmp/tracker_test_cache')
  end
end
