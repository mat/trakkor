require 'rubygems'
require 'open-uri'
require 'xml/libxml'

XML::Parser::default_line_numbers=true

class TrackersController < ApplicationController
  # GET /trackers
  # GET /trackers.xml
  def index
    @trackers = Tracker.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trackers }
    end
  end

  # GET /trackers/1
  # GET /trackers/1.xml
  def show
    @tracker = Tracker.find(params[:id])

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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tracker }
    end
  end

  def test
    @tracker = Tracker.new

    @tracker.uri = params[:uri]
    @tracker.domnode = params[:domnode]

    uri = '/home/mat/svn_workspaces/ruby/scraper/test_simple.html'
    remote_uri = 'http://localhost:8808/doc_root/activerecord-2.0.1/rdoc/index.html'

    uri = remote_uri

    uri = @tracker.uri

    @complete_html = open(uri) { |f| f.read }

    libxmldoc  = XML::HTMLParser.string(@complete_html).parse

    libxml_fragment = libxmldoc.find(@tracker.domnode)

      if libxml_fragment and libxml_fragment.length > 0
        flash[:notice] = "DOM elem found in uri, #{libxml_fragment.set.length} matches" 
    	@domnode_html = libxml_fragment.set.first.to_s
	@domnode_text = libxml_fragment.set.first.content
        @found_in_line = libxml_fragment.set.first.line_num
    	#@domnode_html = libxml_fragment.first.parent.to_a.first.to_s
	#@domnode_text = libxml_fragment.first.parent.to_a.first.content
      else
        flash[:notice] = ' Cannot find DOM elem designated by given xpath.'
    	@domnode_html = 'nix'
	@domnode_text = 'nix'
      end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tracker }
    end
  end

  # GET /trackers/1/edit
  def edit
    @tracker = Tracker.find(params[:id])
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

    respond_to do |format|
      format.html { redirect_to(trackers_url) }
      format.xml  { head :ok }
    end
  end
end
