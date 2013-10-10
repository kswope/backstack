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

    # Normalize controller and action to "controller#action", unless
    # second param already has "#".  This is up here in the class methods
    # because normalizing controller/actions is utilized both here
    # and in the ApplicationControllers objects
    def bs_action_normal(controller, x)
      x.to_s.index("#") ? "#{x}" : "#{controller}##{x}"
    end

    # This is the "macro" you put at the top of your controllers
    def backstack(edges)

      # Note: its a little hard to follow but @bs_graph is a instance
      # variable of the class ApplicationController::Base (not an
      # object of AC::B).  There will only be one in the rails runtime,
      # and may behave differently depending on whether we're in dev
      # or prod mode, because dev mode reloads classes with each
      # request, and prod hopefully doesn't.  We'll write this module
      # to work correctly under both circumstances.

      # In rails we're going to use the string "controller#action" to
      # identify the page.  We're NOT going to let bs_add_edges
      # normalize that because it might be used for other frameworks.
      # If the user didn't pass in the controller we'll add it here.
      # The complete value should look like "controller#action", for
      # both keys and values.
      normalizer = lambda {|x| bs_action_normal(controller_name, x) }

      # Add new edges to existing graph, and extract out the labels.
      # bs_add_edges will also accumulate labels for us.
      @bs_graph, @bs_labels = bs_add_edges(@bs_graph, @bs_labels,
                                          edges, normalizer)

    end

    # So ApplicationController methods can reach @bs_graph and
    # @bs_labels.  I wanted to use @@bs_graph, so both AC::B and the
    # instance of AC could reach it, but this mysteriously breaks
    # rails routing!  So here are getters than we can use and access
    # from the AC instance as self.class.get_bs_graph.  RoR can be a
    # real pit of dispair sometimes.
    def get_bs_graph
      @bs_graph || {}
    end

    def get_bs_labels
      @bs_labels || {}
    end

    send :include, InstanceMethods

  end

  # These functions will be available in views
  module Helpers

    def backstack_link(text, *args)

      bs_graph = controller.class.get_bs_graph # found it! lol

      # If we don't have these we can't do anything
      return unless session[:bs_stack] && bs_graph

      # If the top of stack (current location) is stacked on top of
      # link the graph indicates it closes to, then create a link from
      # that.
      current = session[:bs_stack][-1]
      previous = session[:bs_stack][-2]

      if current && previous && bs_graph[current.first].include?(previous.first)
        return link_to(text, previous.second, *args)
      end

    end

    # Iterator to build breadcrumb trails
    def backstack_trail

      hashify = lambda{|x|
        c, a = x[0].split /#/
        label = x[2] || "#{a.capitalize}" # if forgot
        {:controller => c, :action => a, :fullpath => x[1], :label => label}
      }

      if block_given?
        session[:bs_stack].each { |x| yield hashify.call(x) }
      else # return an array
        session[:bs_stack].map { |x| hashify.call(x) }
      end

    end

  end


end


ActionController::Base.send :include, BackStack

# ActionView::Helpers.send :include, BackStack::Helpers
ActionView::Base.send :include, BackStack::Helpers


# note, do not do this here:
# class ApplicationController < ActionController::Base
# it will prevent application_controller.rb from loading
class ActionController::Base

  include BackStackLib

  # Debugging method for calling inside controller, probably best as
  # before_filter :backstack_dump
  # in application_controller.rb
  def backstack_dump

    # don't accidentally run in production
    return unless Rails.env == 'development'

    puts "=== backstack_dump() " + '=' * 50

    puts "backstack graph: #{self.class.get_bs_graph}"
    puts "backstack labels: #{self.class.get_bs_labels}"
    puts "backstack stack: #{session[:bs_stack]}"

    puts '=' * 71

  end



  def bs_pusher

    action = self.class.bs_action_normal(controller_name, action_name)

    session[:bs_stack] = bs_push(self.class.get_bs_graph,
                                 session[:bs_stack],
                                 action,
                                 request.fullpath,
                                 self.class.get_bs_labels[action])

  end

  before_filter :bs_pusher

end


