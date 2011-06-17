require "backstacklib"


module BackStack

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module InstanceMethods
    # maybe later
  end

  module ClassMethods

    include BackStackLib

    # normalize controller and action to "controller#action", unless
    # second param already has "#".  This is up here in the class methods
    # because normalizing controller/actions is utilized both here
    # and in the ApplicationControllers objects
    def bs_action_normal(controller, x)
      x.to_s.index("#") ? "#{x}" : "#{controller}##{x}"
    end

    def backstack(edges)

      # Note: its a little hard to follow but @bs_graph is a instance
      # variable of the class ApplicationController::Base (not an
      # object of AC::B).  There will only be one in the rails runtime,
      # and may behave differently depending on whether we're in dev
      # or prod mode, because dev mode reloads classes with each
      # request, and prod hopefully doesn't.  We'll write this module
      # to work correctly under both circumstances.

      # add new edges to existing graph
      @bs_graph = bs_add_edges(@bs_graph, edges)

      # lets get names out of there before we do anything else
      @bs_graph, @bs_names = bs_strip_names(@bs_graph)

      # In rails we're going to use the string "controller#action" to
      # identify the page.  We're NOT going to let bs_add_edges
      # normalize that because it might be used for other frameworks.
      # If the user didn't pass in the controller we'll add it here.
      # The complete value should look like "controller#action", for
      # both keys and values.

      normalizer = lambda {|x| bs_action_normal(controller_name, x) }

      @bs_graph = @bs_graph.inject({}) do |h, (k, v)|
        h[normalizer[k]] = v.map {|x| normalizer[x] }
        h
      end

      puts "@bs_graph #{@bs_graph}"

    end

    # So ApplicationController methods can reach @bs_graph and
    # @bs_names.  I wanted to use @@bs_graph, so both AC::B and the
    # instance of AC could reach it, but this mysteriously breaks
    # rails routing!  So here are getters than we can use and access
    # from the AC instance as self.class.get_bs_graph.  RoR can be a
    # real pit of dispair sometimes.
    def get_bs_graph
      @bs_graph
    end

    def get_bs_names
      @bs_names
    end

    send :include, InstanceMethods

  end

  # these functions will be available in views
  module Helpers

    def backstack_link(text)

      bs_graph = controller.class.get_bs_graph # found it! lol

      # if we don't have these we can't do anything
      return unless session[:bs_stack] && bs_graph

      # if the top of stack (current location) is stacked on top of
      # link the graph indicates it closes to, then create a link from
      # that.
      current = session[:bs_stack][-1]
      previous = session[:bs_stack][-2]

      if bs_graph[current.first].include?(previous.first)
        return link_to(text, previous.second)
      end

    end

  end


end


ActionController::Base.send :include, BackStack

ActionView::Helpers.send :include, BackStack::Helpers


# Have to open this here because ApplicationController is not defined
# yet so we can't stick a before_filter on it - this is my best guess
# right now.
class ApplicationController < ActionController::Base

  include BackStackLib

  
  def bs_action
    [self.class.bs_action_normal(controller_name, action_name), request.fullpath]
  end

  def bs_pusher

    session[:bs_stack] = bs_push(self.class.get_bs_graph,
                                 session[:bs_stack], 
                                 bs_action)

    puts "bs_stack #{session[:bs_stack]}"

  end

  before_filter :bs_pusher

end


