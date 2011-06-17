# BackStackLib should know nothing about rails, sinatra or whatever
# framework this gem is supporting.  It should also have no storage of
# its own.  Keep it that way.
module BackStackLib

  # Combine a "graph", described by connected nodes, in hash form,
  # with another.
  #
  # Input graph must be normalized and described like this (could also
  # be {}).  Normalized means key is not a collection data type (not
  # an array) but the value IS an array.
  #
  # An example is {:b=>[:a], :c=>[:a]} which reads "b is connected to
  # a and c is connected to a", or more relevantly "b closes to a and
  # c closes to a".
  #
  # When method is run it combines the *already* normalized graph
  # (could be {}), with a another graph description, which for
  # convenience can be in more of a shorthand, like {[:f, :e, :d] =>
  # :c}, which reads "f, e, and d all close to c"
  #
  # The returned value will be a combination of the graphs, in a
  # normalized form, for example {:b=>[:a], :c=>[:a], :f=>[:b, :c],
  # :e=>[:b, :c], :d=>[:b, :c]}
  #
  # Note: the shorthand form of the edges parameter can be taken as far as
  # something like this {[:d, :e, :f] => [:b, :c]}
  #
  # New feature: named nodes.  Instead of {:c => :a}, the "key" can be
  # named like this {{:c => "Charlie"} => :a}.  At the moment I'm
  # guessing that this will require no rewriting in this method.
  def bs_add_edges(graph, edges)

    graph ||= {}

    edges.each do |k,v| # k is a scalar or array, same with v

      [k].flatten.each do |x|

        graph.merge!(x => [v].flatten) do |key, old_v, new_v|
          [old_v, new_v].flatten
        end

      end

    end

    graph

  end

  # Judging by graph, push onto stack if appropriate.  Pushing doesn't
  # necessarily build stack up, it might cause a rewind and actually
  # shrink stack.
  def bs_push(graph, stack, action_full)

    # bs_push might be called before there is a graph or stack
    graph ||= {}
    stack ||= []

    action = action_full.first

#     puts "==============="
#     puts "graph #{graph}"
#     puts "stack #{stack}"
#     puts "action #{action}"
#     puts "graph[action] #{graph[action]}"
#     puts "stack.last #{stack.last}"

    # if action closes to what's on top of stack, build stack up
    if graph[action] && stack.last && graph[action].include?(stack.last.first)
      stack.push action_full
      return stack
    end

    # if action already in stack rewind *past* it and place on stack
    # (we rewind past it and push because the path part might be
    # different)
    if i = stack.find_index {|x| x.first == action}
      stack = stack.slice(0,i)
      stack.push action_full
      return stack
    end

    # if none of the clever stuff above happened then just replace top
    # of stack
    if stack.empty?
      return [action_full]
    else
      stack[-1] = action_full
      return stack
    end

  end

  # Separate names out from the graph data structure.
  #
  # Note: to make things a lot easier *make sure* the input is
  # normalized, in other words, run it through bs_add_edges first.
  # Its a lot easier and probably not as buggy to normalize a simple
  # datastructure with "names" than to strip them out while keeping
  # the structure intact.
  #
  # Example: given {{:c => "Charlie"} => :a}
  #
  # returns a hash:
  # {:edges => {:c => :a}, :names => {:c => "Charlie"}}
  def bs_strip_names(graph)

    names_only = {}
    edges_only = {}

    graph.each do |k,v|

      # Because its normalized (right?) k can only be a single value
      # or a size 1 hash
      if k.class == Hash
        names_only[k.first.first] = k.first.last
        edges_only[k.first.first] = v
      else
        edges_only[k] = v
      end

    end

    [edges_only, names_only]

  end


end
