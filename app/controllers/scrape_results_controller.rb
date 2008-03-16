class ScrapeResultsController < ApplicationController
  # GET /scrape_results
  # GET /scrape_results.xml
  def index
    @scrape_results = ScrapeResult.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scrape_results }
    end
  end

  # GET /scrape_results/1
  # GET /scrape_results/1.xml
  def show
    @scrape_result = ScrapeResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scrape_result }
    end
  end

  # GET /scrape_results/new
  # GET /scrape_results/new.xml
  def new
    @scrape_result = ScrapeResult.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scrape_result }
    end
  end

  # GET /scrape_results/1/edit
  def edit
    @scrape_result = ScrapeResult.find(params[:id])
  end

  # POST /scrape_results
  # POST /scrape_results.xml
  def create
    @scrape_result = ScrapeResult.new(params[:scrape_result])

    respond_to do |format|
      if @scrape_result.save
        flash[:notice] = 'ScrapeResult was successfully created.'
        format.html { redirect_to(@scrape_result) }
        format.xml  { render :xml => @scrape_result, :status => :created, :location => @scrape_result }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scrape_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scrape_results/1
  # PUT /scrape_results/1.xml
  def update
    @scrape_result = ScrapeResult.find(params[:id])

    respond_to do |format|
      if @scrape_result.update_attributes(params[:scrape_result])
        flash[:notice] = 'ScrapeResult was successfully updated.'
        format.html { redirect_to(@scrape_result) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scrape_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scrape_results/1
  # DELETE /scrape_results/1.xml
  def destroy
    @scrape_result = ScrapeResult.find(params[:id])
    @scrape_result.destroy

    respond_to do |format|
      format.html { redirect_to(scrape_results_url) }
      format.xml  { head :ok }
    end
  end
end
