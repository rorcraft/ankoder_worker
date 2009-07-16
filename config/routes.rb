ActionController::Routing::Routes.draw do |map|
  map.connect ":controller/:action"
  map.connect ":controller/:id.:id/worker/:action"
end
