ActionController::Routing::Routes.draw do |map|
  map.find_xpath  "/find",       :controller => 'trackers', :action => 'find_xpath'
  map.test_xpath  "/test-xpath", :controller => 'trackers', :action => 'test_xpath'
  map.stats       "/stats",      :controller => 'trackers', :action => 'stats'

  map.resources :trackers
  map.resources :trackers, :member => { :delete => :get }

  map.connect "no_one_may_see_my_exceptions/:action/:id", :controller => "logged_exceptions"

  map.root :controller => "trackers", :action => 'index'

  map.connect ":controller/:action/:id"
  map.connect ":controller/:action/:id.:format"
end
