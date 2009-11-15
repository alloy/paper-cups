ActionController::Routing::Routes.draw do |map|
  map.resources :members
  map.resources :memberships
  map.resources :passwords
  map.resources :rooms do |room|
    room.resources :members
    room.messages_on_day '/messages/:day', :controller => 'messages', :action => 'index', :requirements => { :day => /\d{4}-\d{2}-\d{2}/ }
    room.resources :messages
  end
  map.resource  :session, :collection => { :clear => :get }
  
  map.root :controller => "rooms", :action => "index"
end
