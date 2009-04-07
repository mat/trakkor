ActionController::Routing::Routes.draw do |map|
  #map.resources :pieces
  
  map.find_xpath "/trackers/find-xpath", :controller => 'trackers', :action => 'find_xpath'
  map.test_xpath "/trackers/test-xpath", :controller => 'trackers', :action => 'test_xpath'
  map.stats "/trackers/stats", :controller => 'trackers', :action => 'stats'
  map.examples "/trackers/examples", :controller => 'trackers', :action => 'examples'
  map.web_hook "/trackers/web_hook", :controller => 'trackers', :action => 'web_hook'

  #map.tracker "#{prefix}:id", :controller => 'trackers', :action => 'show' 
  #map.trackers ":id", :controller => 'trackers', :action => 'show' 

  #map.connect "#{prefix}:id.:format", :controller => 'trackers', :action => 'show'


  map.resources :trackers

  map.connect "no_one_may_see_my_exceptions/:action/:id", :controller => "logged_exceptions"

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "trackers", :action => 'index'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  #

  map.connect ":controller/:action/:id"
  map.connect ":controller/:action/:id.:format"
end
