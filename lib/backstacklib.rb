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
  # In other words, don't pass as the first argument anything that hasn't
  # been already normalized by this method, or use {} to start
  #
  # An example of normalized is {:b=>[:a], :c=>[:a], :z=>[:a, :x]}
  # which reads "b is connected to a and c is connected to a and z is
  # connected to both :a and :x", or more relevantly "b closes to a
  # and c closes to a and z closes to both a and x".
  #
  # When this method is run it combines the *already* normalized graph
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
  # New feature: labeled nodes.  Instead of {:c => :a}, the "key" can be
  # labeled like this {{:c => "Charlie"} => :a}.  We're going to remove
  # those labeled keys, replace them with just the key, and return them as
  # the second value
  #
  # Decided to allow user to pass a normalizer proc/lambda in to
  # modify all the keys and values.
  def bs_add_edges(graph, labels, edges, normalizer=nil)

    graph ||= {}
    labels ||= {}

    edges.each do |k,v| # k is a scalar or array, same with v

      # Does this [x].flatten idiom make it less readable?
      [k].flatten.each do |x|

        # Extract labels out into their own hash, and normalize key
        if x.class == Hash # if its a hash it contains a label
          labels[x.first[0]] = x.first[1]
          x = x.first[0] # remove label and replace with normal key
        end

        # Run normalizer on all keys and values of new edges
        if normalizer
          x = normalizer.call(x)
          v = [v].flatten.map{|y| normalizer.call(y)}
          # also run normalizer on labels keys
          labels = Hash[labels.map {|k,v| [normalizer.call(k), v]}]
        end

        # If merge finds dupe keys it will use block to determine
        # value, which in our case is to combine the two values.
        graph.merge!(x => [v].flatten) do |key, old_v, new_v|
          [old_v, new_v].flatten
        end

      end

    end

    [graph, labels]

  end

  # Judging by graph, push onto stack if appropriate.  Pushing doesn't
  # necessarily build stack up, it might cause a rewind and actually
  # shrink stack.
  def bs_push(graph, stack, action, fullpath, label=nil)

    # bs_push might be called before there is a graph or stack
    graph ||= {}
    stack ||= []

    element = [action, fullpath, label]

    # if action closes to what's on top of stack, build stack up
    if graph[action] && stack.last && graph[action].include?(stack.last.first)
      stack.push element
      return stack
    end

    # if action already in stack rewind *past* it and place on stack
    # (we rewind past it and push because the path part might be
    # different)
    if i = stack.find_index {|x| x.first == action}
      stack = stack.slice(0,i)
      stack.push element
      return stack
    end

    # if none of the clever stuff above happened then just replace top
    # of stack
    if stack.empty?
      return [element]
    else
      stack[-1] = element
      return stack
    end

  end

end
