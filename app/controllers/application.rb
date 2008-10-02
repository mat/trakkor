# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '32f679ed8e66648795a7a54f92f7ae47'

  around_filter do |controller, action|
    if controller.params.key?("wooza!")
      require 'ruby-prof'
  
      # Profile only the action
      profile_results = RubyProf.profile { action.call }
  
      # Use RubyProf's built in HTML printer to format the results
      printer = RubyProf::GraphHtmlPrinter.new(profile_results)
  
      # Append the results to the HTML response
      controller.response.body << printer.print("", 0)
    else
      action.call
    end
  end   


  include ExceptionLoggable # exception_logger

  private
  def local_request?
    false
  end

end
