require 'helper'

class TestBackstack < MiniTest::Unit::TestCase

  include BackStackLib

  def test_push

    # Note: even though we use symbols here its more likely the rails
    # plugin will use strings.  I'm not sure what any other plugins
    # will use.  The tested methods here should be string agnostic
    # anyway.

    # def bs_push(graph, stack, action, fullpath, name=nil)

    # starting with nothing in stack
    graph = {:c => [:a]}
    stack = []
    stack = bs_push(graph, stack, :a, :path_a)
    assert_equal [[:a, :path_a, nil]], stack

    # starting with nothing in stack, with name
    graph = {:c => [:a]}
    stack = []
    stack = bs_push(graph, stack, :a, :path_a, :name)
    assert_equal [[:a, :path_a, :name]], stack

    # further up graph
    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a, nil]]
    stack = bs_push(graph, stack, :c, :path_c)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil]], stack

    # reload of above, different path
    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a, nil], [:c, :path_c, nil]]
    stack = bs_push(graph, stack, :c, :path_c2)
    assert_equal [[:a, :path_a, nil], [:c, :path_c2, nil]], stack

    # graph miss
    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a]]
    stack = bs_push(graph, stack, :z, :path_z)
    assert_equal [[:z, :path_z, nil]], stack

    # back down
    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a, nil], [:c, :path_c, nil], [:f, :path_f, nil]]
    stack = bs_push(graph, stack, :c, :path_c2)
    assert_equal [[:a, :path_a, nil], [:c, :path_c2, nil]], stack

    # back down further
    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a, nil], [:c, :path_c, nil]]
    stack = bs_push(graph, stack, :a, :path_a2)
    assert_equal [[:a, :path_a2, nil]], stack

    # side stepping
    graph = {:b => [:a], :c => [:a]}
    stack = [[:a, :path_a, nil], [:c, :path_c, nil]]
    stack = bs_push(graph, stack, :b, :path_b)
    assert_equal [[:a, :path_a, nil], [:b, :path_b, nil]], stack

    ### lots of movement

    g = {:b => [:a], :c => [:a], :d => [:b, :c], :e => [:b, :c], :f => [:b, :c]}
    stack = []

    stack = bs_push(g, stack, :a, :path_a)
    assert_equal [[:a, :path_a, nil]], stack

    stack = bs_push(g, stack, :b, :path_b)
    assert_equal [[:a, :path_a, nil], [:b, :path_b, nil]], stack

    stack = bs_push(g, stack, :c, :path_c)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil]], stack

    stack = bs_push(g, stack, :f, :f_path)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil], [:f, :f_path, nil]], stack

    stack = bs_push(g, stack, :e, :path_e)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil], [:e, :path_e, nil]], stack

    stack = bs_push(g, stack, :c, :path_c)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil]], stack

    stack = bs_push(g, stack, :a, :path_a)
    assert_equal [[:a, :path_a, nil]], stack

  end


  def test_bs_add_edges

    graph = {} # existing graph
    edges = {:c => :a} # new edges
    xp_graph = {:c => [:a]}
    xp_names = {}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, edges)

    graph = {:b => [:a]}
    edges = {:c => :a} # value is not array
    xp_graph = {:b => [:a], :c => [:a]}
    xp_names = {}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, edges)

    graph = {:b => [:a]}
    edges = {:c => [:a]} # value is already array
    xp_graph = {:b => [:a], :c => [:a]}
    xp_names = {}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, edges)

    graph = {:b => [:a]}
    edges = {:c => [:a], :c => [:a]} # dupe
    xp_graph = {:b => [:a], :c => [:a]}
    xp_names = {}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, edges)

    graph = {:b => [:a], :c => [:a]}
    edges = {[:d, :e, :f] => [:b, :c]} # shorthand
    xp_graph = {:b => [:a], :c => [:a], :d => [:b, :c], :e => [:b, :c], :f => [:b, :c]}
    xp_names = {}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, edges)

    # cumulative (names are ignored because aren't cumulative)
    graph, _names = bs_add_edges({}, {:c => :a})
    graph, _names = bs_add_edges(graph, {:b => [:a]})
    graph, _names = bs_add_edges(graph, {[:d, :e, :f] => [:b, :c]})
    xp_graph = {:c=>[:a], :b=>[:a], :d=>[:b, :c], :e=>[:b, :c], :f=>[:b, :c]}
    assert_equal [xp_graph, {}], [graph, _names]

    # with named nodes
    graph = {} # graph is empty
    edges = {{:c => "Charlie"} => :a}
    xp_graph = {:c => [:a]}
    xp_names = {:c => "Charlie"}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, edges)

    graph = {}
    edges = {{:c => "Charlie"} => :a}
    xp_graph = {:c => [:a]}
    xp_names = {:c => "Charlie"}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, edges)

    graph = {:b => [:a]}
    edges = {{:c => "Charlie"} => :a}
    xp_graph = {:b => [:a], :c => [:a]}
    xp_names = {:c => "Charlie"}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, edges)

    # test normalizer
    normalizer = lambda {|x| x.next }

    graph = {:b => [:a]}
    edges = {{:c => "Charlie"} => :a}
    xp_graph = {:b => [:a], :d => [:b]}
    xp_names = {:d => "Charlie"}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, edges, normalizer)

  end

end


