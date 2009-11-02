ActionController::Routing::Routes.draw do |map|
  map.resources :members
  map.resources :passwords
  map.resources :rooms do |room|
    room.resources :messages
  end
  map.resource  :session, :collection => { :clear => :get }
  
  map.root :controller => "members", :action => "new"
end
