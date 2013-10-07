class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :backstack_dump # for debugging

end
