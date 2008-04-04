require 'rubygems'
require 'hpricot'
require 'hpricot/inspect-html'
require 'cache'

class TrackersController < ApplicationController

  caches_page :index, :examples, :show

  # GET /trackers
  # GET /trackers.xml
  def index
    @trackers = [Tracker.find(3)] + [Tracker.find(1)] + [Tracker.find(2)]

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
      data = cache.get(@uri)
      unless data
        data = Tracker.fetch(@uri).body
        cache.set(@uri, data)
      end

      @foo = "/test?uri=#{@uri}&xpath=#{@xpath}"

      doc = Hpricot.parse(data)
      @complete_html = PP.pp(doc.root, "")
      @complete_html.gsub!(/#XPATH#(.*)#\/XPATH#/, "/moduri/test?uri=#{@uri}&xpath=#{"\\1"}")

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

  def cache
    FileCache.new('tmp/tracker_test_cache')
  end
end
