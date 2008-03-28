ActionController::Routing::Routes.draw do |map|
  #map.resources :pieces
  prefix='moduri/'
  
  map.index "#{prefix}", :controller => 'trackers', :action => 'index' 
  map.test "#{prefix}test", :controller => 'trackers', :action => 'test' 
  map.stats "#{prefix}stats", :controller => 'trackers', :action => 'stats' 
  map.examples "#{prefix}examples", :controller => 'trackers', :action => 'examples' 
  map.new "#{prefix}new", :controller => 'trackers', :action => 'new' 

  map.tracker "#{prefix}:id", :controller => 'trackers', :action => 'show' 
  map.trackers "#{prefix}:id", :controller => 'trackers', :action => 'show' 

  map.connect "#{prefix}:id.:format", :controller => 'trackers', :action => 'show'


  #map.resources :trackers


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
  #map.root :controller => "trackers"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  #



  map.connect "#{prefix}:controller/:action/:id"
  map.connect "#{prefix}:controller/:action/:id.:format"
end
