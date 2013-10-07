Rails4::Application.routes.draw do

  root :to => "c1#a"

  get ':controller(/:action(/:id(.:format)))'

end
