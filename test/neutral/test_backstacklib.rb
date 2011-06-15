require 'helper'

class TestBackstack < MiniTest::Unit::TestCase

  include BackStackLib

  def test_push

    # starting with nothing in stack
    graph = {:c => [:a]}
    stack = []
    stack = bs_push(graph, stack, :a, :c)
    assert_equal [:a], stack

    # further up graph
    graph = {:c => [:a], :f => [:c]}
    stack = [:a]
    stack = bs_push(graph, stack, :c, :f)
    assert_equal [:a, :c], stack

    # reload of above
    graph = {:c => [:a], :f => [:c]}
    stack = [:a, :c]
    stack = bs_push(graph, stack, :f, :f)
    assert_equal [:a, :c], stack

    # back down
    graph = {:c => [:a], :f => [:c]}
    stack = [:a, :c]
    stack = bs_push(graph, stack, :f, :c)
    assert_equal [:a], stack

    # back down further
    graph = {:c => [:a], :f => [:c]}
    stack = [:a]
    stack = bs_push(graph, stack, :c, :a)
    assert_equal [], stack

    # side stepping
    graph = {:b => [:a], :c => [:a]}
    stack = [:a]
    stack = bs_push(graph, stack, :c, :b)
    assert_equal [:a], stack

    # lots of movement

    g = {:b => [:a], :c => [:a], :d => [:b, :c], :e => [:b, :c], :f => [:b, :c]}

    stack = []

    stack = bs_push(g, stack, :a, :b)
    assert_equal [:a], stack

    stack = bs_push(g, stack, :b, :c)
    assert_equal [:a], stack

    stack = bs_push(g, stack, :c, :f)
    assert_equal [:a, :c], stack

    stack = bs_push(g, stack, :f, :d)
    assert_equal [:a, :c], stack

    stack = bs_push(g, stack, :e, :c)
    assert_equal [:a], stack

    stack = bs_push(g, stack, :c, :a)
    assert_equal [], stack

    stack = bs_push(g, stack, :a, :b)
    assert_equal [:a], stack

    stack = bs_push(g, stack, :b, :f)
    assert_equal [:a, :b], stack

    # This motion is inconsistent with a rule of the backstack - only
    # go back using the close links, don't go back another way (should
    # this be a problem? seems like bad UX anyway)
    stack = bs_push(g, stack, :f, :c) 
    refute_equal [:a], stack

  end


  def test_bs_add_edges

    graph = {} # graph is empty
    edges = {:c => :a}
    xp = {:c => [:a]}
    assert_equal xp, bs_add_edges(graph, edges)    

    graph = {:b => [:a]}
    edges = {:c => :a} # value is not array
    xp = {:b => [:a], :c => [:a]}
    assert_equal xp, bs_add_edges(graph, edges)    

    graph = {:b => [:a]}
    edges = {:c => [:a]} # value is array
    xp = {:b => [:a], :c => [:a]}
    assert_equal xp, bs_add_edges(graph, edges)

    graph = {:b => [:a]}
    edges = {:c => [:a], :c => [:a]} # dupe
    xp = {:b => [:a], :c => [:a]}
    assert_equal xp, bs_add_edges(graph, edges)

    graph = {:b => [:a], :c => [:a]}
    edges = {[:d, :e, :f] => [:b, :c]} # shorthand
    xp = {:b => [:a], :c => [:a], :d => [:b, :c], :e => [:b, :c], :f => [:b, :c]}
    assert_equal xp, bs_add_edges(graph, edges)

    # cumulative
    graph = {}
    edges = {:c => :a}
    graph = bs_add_edges(graph, edges)
    edges = {:b => [:a]}
    graph = bs_add_edges(graph, edges)
    edges = {[:d, :e, :f] => [:b, :c]}
    graph = bs_add_edges(graph, edges)
    xp = {:c=>[:a], :b=>[:a], :d=>[:b, :c], :e=>[:b, :c], :f=>[:b, :c]}
    assert_equal( xp, graph )

    # with named nodes
    graph = {} # graph is empty
    edges = {{:c => "Charlie"} => :a}
    xp = {{:c => "Charlie"} => [:a]}
    assert_equal xp, bs_add_edges(graph, edges)    

    graph = {{:b => "Bravo"} => [:a]}
    edges = {{:c => "Charlie"} => :a}
    xp = {{:b => "Bravo"} => [:a], {:c => "Charlie"} => [:a]}
    assert_equal xp, bs_add_edges(graph, edges)    


  end


  # Note: bs_strip_names only takes normalized data, which is output
  # by bs_add_edges.  In other words, either 
  # {:c => :a} or {{:c => "Charlie"} => :a}
  def test_bs_strip_names


    # no names
    edges = {:c => [:a]}
    graph, names = bs_strip_names(edges)
    assert_equal( {:c => [:a]} , graph )
    assert_equal( {}, names )

    # one name
    named_edges = {{:c => "Charlie"} => [:a]}
    graph, names = bs_strip_names(named_edges)
    assert_equal( {:c => [:a]}, graph )
    assert_equal( {:c => "Charlie"}, names )

    # multiple names
    named_edges = { {:c => "Charlie"} => [:a], {:b => "Bravo"} => [:a] }
    graph, names = bs_strip_names(named_edges)
    assert_equal( {:c => [:a], :b => [:a]}, graph )
    assert_equal( {:c => "Charlie", :b => "Bravo"}, names )



  end



end


