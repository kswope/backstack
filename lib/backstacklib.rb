# BackStackLib should know nothing about rails, sinatra or whatever
# framework this gem is supporting.  It should also have no storage of
# its own.  Keep it that way.
module BackStackLib

  # Combine a "graph" described by connected nodes in a hash with more
  # of the same (sorry but this isn't easy to describe, but there
  # should be plenty of tests).
  #
  # Input graph is normalized and described like this (could also be
  # {}).  Note: "normalized" means key is not a collection data type
  # (not an array) but the value IS an array.
  #
  # An example is {:b=>[:a], :c=>[:a]} which reads "b is connected to
  # a and c is also connected to a".
  #
  # When method is run it combines the normalized graph (could be {}),
  # with a another graph description, which for convenience can be in
  # more of a shorthand, like {[:f, :e, :d] => :c}, which reads "f, e,
  # and d are all connected to c"
  #
  # The returned value will be a combination of the graphs, in a
  # normalized form, for example {:b=>[:a], :c=>[:a], :f=>[:b, :c],
  # :e=>[:b, :c], :d=>[:b, :c]}
  #
  # Note: the shorthand form of the edges parameter can be taken as far as
  # something like this {[:d, :e, :f] => [:b, :c]}
  #
  # New feature: also takes named nodes.  Instead of {:c => :a}, the
  # "key" can be named like this {{:c => "Charlie"} => :a}.  At the
  # moment I'm guessing that this will require no rewriting.
  def bs_add_edges(graph, edges)

    graph ||= {}
    edges ||= {}

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
  def bs_push(graph, stack, previous, current, fullpath)

    graph ||= {}
    stack ||= []

    # if current exists on stack we need to rewind past it.
    if i = stack.index(current)
      stack = stack.slice(0, i)
    end

    # if we have an "edge hit" then push previous to stack
    if graph[current] && graph[current].include?(previous)
      stack.push previous
    end

    stack

  end

  # Separate names out from edges data structure.
  # NOTE: to make things a lot easier make sure the input is normalized,
  # in other words, run it through bs_add_edges first.  Its a lot easier
  # and probably not as buggy to normalize a simple datastructure with "names"
  # than to strip them out while keeping the structure intact.
  # Example:
  # given {{:c => "Charlie"} => :a}
  # or
  # not normalized, nono {[{:c => "Charlie"}] => :a}
  # returns:
  # {:edges => {:c => :a}, :names => {:c => "Charlie"}}
  def bs_strip_names(graph)

    graph ||= {}
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
