require 'rubygems'
require 'hpricot'
require 'hpricot/inspect-html'

class TrackersController < ApplicationController
  protect_from_forgery :except => [:changes_and_errors]

  def index
    expires_in 2.minutes, :private => false
    examples = Tracker.live_examples

    last_modified = examples.map{|t| t.last_modified}.max
    fresh_when(:last_modified => last_modified, :public => true)

    @trackers = examples
  end

  def show
    expires_in 5.minutes, :private => false
    @tracker = Tracker.find_by_md5sum(params[:id])

    unless @tracker
      render :text => 'No tracker found for this id.', :status => 404
      return
    end

    if stale?(:last_modified => @tracker.last_modified, :public => true)
      @changes = @tracker.changes

      if(params[:errors] == 'show')
        if(@tracker.sick?)
          @changes += @tracker.sick?  # add 10 most recent errors
          @changes = @changes.sort{ |a,b|  -(a.created_at <=> b.created_at) }
        end
      end

      respond_to do |format|
        format.html # show.html.erb
        format.atom
        format.microsummary do
          txt = ''
          txt = @tracker.last_change.text unless @tracker.last_change.nil?
          render :text => "Trakkor: #{txt}"
        end
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

       if @tracker.name.blank?
         html_title = @tracker.html_title.to_s
         html_title = "#{html_title[0..50]}..." if html_title.length > 50
         @tracker.name = "Tracking '#{html_title}'"
       end
    end
  end

  def find_xpath
    @hits = flash[:error] = nil
    @uri    = params[:uri]
    @q = params[:q]

    if @uri.blank? || @q.blank?
      flash[:error] = "Please provide an URI and a search term."
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
        flash[:error] = "URI does not point to a text document " +
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
    
    if @uri.blank? || @xpath.blank?
      flash[:error] = "Please provide an URI and an XPath."
      return 
    end
      
     doc = fetch_doc_from(@uri)
     @elem, @parents = Piece.extract_with_parents(doc, @xpath) if doc
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

  def destroy
    @tracker = Tracker.find_by_md5sum(params[:id])
    redirect_to(stats_path) and return if params[:cancel]
    @tracker.destroy
    respond_to do |format|
      format.html { redirect_to stats_path }
    end
  end

  def delete
    @tracker = Tracker.find_by_md5sum(params[:id])
    respond_to do |format|
      format.html # delete.html.erb
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic("Trakkor stats") do |username, password|
      username == "admin" && password == APP_CONFIG['password']
    end
  end
end
