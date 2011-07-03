RailsRoot::Application.routes.draw do

  get "c4/g"

  get "c4/h"

  get "c4/i"

  get "c4/j"

  root :to => "c1#a"

  match ':controller(/:action(/:id(.:format)))'

end
