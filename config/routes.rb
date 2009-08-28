ActionController::Routing::Routes.draw do |map|
  map.connect ":controller/:action", :controller => :h, :action => :gth
  map.connect ":controller/:id.:id/worker/:action", :controller => :h, :action => :gth
end
