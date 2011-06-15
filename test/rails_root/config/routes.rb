RailsRoot::Application.routes.draw do

  root :to => "c1#a"

  match ':controller(/:action(/:id(.:format)))'

end
