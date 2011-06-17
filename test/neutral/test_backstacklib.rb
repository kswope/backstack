require 'helper'

class TestBackstack < MiniTest::Unit::TestCase

  include BackStackLib

  def test_push

    # Note: even though we use symbols here its more likely the rails
    # plugin will use strings.  I'm not sure what any other plugins
    # will use.  The tested methods here should be string agnostic
    # anyway.

    # starting with nothing in stack
    graph = {:c => [:a]}
    stack = []
    stack = bs_push(graph, stack, [:a, :path_a])
    assert_equal [[:a, :path_a]], stack

    # further up graph
    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a]]
    stack = bs_push(graph, stack, [:c, :path_c])
    assert_equal [[:a, :path_a], [:c, :path_c]], stack

    # reload of above, different path
    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a], [:c, :path_c]]
    stack = bs_push(graph, stack, [:c, :path_c2])
    assert_equal [[:a, :path_a], [:c, :path_c2]], stack

    # graph miss
    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a]]
    stack = bs_push(graph, stack, [:z, :path_z])
    assert_equal [[:z, :path_z]], stack

    # back down
    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a], [:c, :path_c], [:f, :path_f]]
    stack = bs_push(graph, stack, [:c, :path_c2])
    assert_equal [[:a, :path_a], [:c, :path_c2]], stack

    # back down further
    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a], [:c, :path_c]]
    stack = bs_push(graph, stack, [:a, :path_a2])
    assert_equal [[:a, :path_a2]], stack


    # side stepping
    graph = {:b => [:a], :c => [:a]}
    stack = [[:a, :path_a], [:c, :path_c]]
    stack = bs_push(graph, stack, [:b, :path_b])
    assert_equal [[:a, :path_a], [:b, :path_b]], stack

    ### lots of movement

    g = {:b => [:a], :c => [:a], :d => [:b, :c], :e => [:b, :c], :f => [:b, :c]}

    stack = []

    stack = bs_push(g, stack, [:a, :path_a])
    assert_equal [[:a, :path_a]], stack

    stack = bs_push(g, stack, [:b, :path_b])
    assert_equal [[:a, :path_a], [:b, :path_b]], stack

    stack = bs_push(g, stack, [:c, :path_c])
    assert_equal [[:a, :path_a], [:c, :path_c]], stack

    stack = bs_push(g, stack, [:f, :f_path])
    assert_equal [[:a, :path_a], [:c, :path_c], [:f, :f_path]], stack

    stack = bs_push(g, stack, [:e, :path_e])
    assert_equal [[:a, :path_a], [:c, :path_c], [:e, :path_e]], stack

    stack = bs_push(g, stack, [:c, :path_c])
    assert_equal [[:a, :path_a], [:c, :path_c]], stack

    stack = bs_push(g, stack, [:a, :path_a])
    assert_equal [[:a, :path_a]], stack

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


