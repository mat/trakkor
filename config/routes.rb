ActionController::Routing::Routes.draw do |map|
  map.find_xpath "/trackers/find-xpath", :controller => 'trackers', :action => 'find_xpath'
  map.test_xpath "/trackers/test-xpath", :controller => 'trackers', :action => 'test_xpath'
  map.stats "/trackers/stats", :controller => 'trackers', :action => 'stats'

  map.resources :trackers

  map.connect "no_one_may_see_my_exceptions/:action/:id", :controller => "logged_exceptions"

  map.root :controller => "trackers", :action => 'index'

  map.connect ":controller/:action/:id"
  map.connect ":controller/:action/:id.:format"
end
