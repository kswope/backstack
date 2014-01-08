require 'helper'

class TestBackstack < MiniTest::Unit::TestCase

  include BackStackLib

  # Note: even though we use symbols here for controllers/actions its more
  # likely the rails plugin will use strings.  I'm not sure what any other
  # plugins will use.  The tested methods here should be string agnostic
  # anyway.

  # def bs_push(graph, stack, ignore, action, fullpath, name=nil)

  def test_starting_with_nothing_on_stack

    graph = {:c => [:a]}
    stack = []
    ignore = []
    stack = bs_push(graph, stack, ignore, :a, :path_a)
    assert_equal [[:a, :path_a, nil]], stack

  end


  def test_starting_with_nothing_on_stack_with_name

    graph = {:c => [:a]}
    stack = []
    ignore = []
    stack = bs_push(graph, stack, ignore, :a, :path_a, :name)
    assert_equal [[:a, :path_a, :name]], stack

  end


  def test_further_up_graph

    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a, nil]]
    ignore = []
    stack = bs_push(graph, stack, ignore, :c, :path_c)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil]], stack

  end


  def test_reload

    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a, nil], [:c, :path_c, nil]]
    ignore = []
    stack = bs_push(graph, stack, ignore, :c, :path_c2)
    assert_equal [[:a, :path_a, nil], [:c, :path_c2, nil]], stack

  end


  def test_graph_miss

    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a]]
    ignore = []
    stack = bs_push(graph, stack, ignore, :z, :path_z)
    assert_equal [[:z, :path_z, nil]], stack

  end


  def test_back_down

    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a, nil], [:c, :path_c, nil], [:f, :path_f, nil]]
    ignore = []
    stack = bs_push(graph, stack, ignore, :c, :path_c2)
    assert_equal [[:a, :path_a, nil], [:c, :path_c2, nil]], stack

  end


  def test_back_down_further

    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a, nil], [:c, :path_c, nil]]
    ignore = []
    stack = bs_push(graph, stack, ignore, :a, :path_a2)
    assert_equal [[:a, :path_a2, nil]], stack

  end


  def test_side_stepping

    graph = {:b => [:a], :c => [:a]}
    stack = [[:a, :path_a, nil], [:c, :path_c, nil]]
    ignore = []
    stack = bs_push(graph, stack, ignore, :b, :path_b)
    assert_equal [[:a, :path_a, nil], [:b, :path_b, nil]], stack

  end


  ### ignore stuff

  def test_not_ignoring_x_collapsing_stack

    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a, nil]]
    ignore = []
    stack = bs_push(graph, stack, ignore, :x, :path_x) # collapses stack
    stack = bs_push(graph, stack, ignore, :c, :path_c)
    assert_equal [[:c, :path_c, nil]], stack

  end


  def test_ignoring_stuff 

    graph = {:c => [:a], :f => [:c]}
    stack = [[:a, :path_a, nil]]
    ignore = [:x, :y]
    stack = bs_push(graph, stack, ignore, :x, :path_x) # wont collapse stack if ignored
    stack = bs_push(graph, stack, ignore, :y, :path_y) # wont collapse stack if ignored
    stack = bs_push(graph, stack, ignore, :c, :path_c)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil]], stack

  end


  def test_lots_of_movement
    g = {:b => [:a], :c => [:a], :d => [:b, :c], :e => [:b, :c], :f => [:b, :c]}
    stack = []
    ignore = []

    stack = bs_push(g, stack, ignore, :a, :path_a)
    assert_equal [[:a, :path_a, nil]], stack

    stack = bs_push(g, stack, ignore, :b, :path_b)
    assert_equal [[:a, :path_a, nil], [:b, :path_b, nil]], stack

    stack = bs_push(g, stack, ignore, :c, :path_c)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil]], stack

    stack = bs_push(g, stack, ignore, :f, :f_path)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil], [:f, :f_path, nil]], stack

    stack = bs_push(g, stack, ignore, :e, :path_e)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil], [:e, :path_e, nil]], stack

    stack = bs_push(g, stack, ignore, :c, :path_c)
    assert_equal [[:a, :path_a, nil], [:c, :path_c, nil]], stack

    stack = bs_push(g, stack, ignore, :a, :path_a)
    assert_equal [[:a, :path_a, nil]], stack

  end


  def test_bs_add_edges

    graph = {} # existing graph
    edges = {:c => :a} # new edges
    names = {}
    xp_graph = {:c => [:a]}
    xp_names = {}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, names, edges)

    graph = {:b => [:a]}
    edges = {:c => :a} # value is not array
    names = {}
    xp_graph = {:b => [:a], :c => [:a]}
    xp_names = {}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, names, edges)

    graph = {:b => [:a]}
    edges = {:c => [:a]} # value is already array
    names = {}    
    xp_graph = {:b => [:a], :c => [:a]}
    xp_names = {}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, names, edges)

    graph = {:b => [:a]}
    edges = {:c => [:a], :c => [:a]} # dupe
    names = {}    
    xp_graph = {:b => [:a], :c => [:a]}
    xp_names = {}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, names, edges)

    graph = {:b => [:a], :c => [:a]}
    edges = {[:d, :e, :f] => [:b, :c]} # shorthand
    names = {}    
    xp_graph = {:b => [:a], :c => [:a], :d => [:b, :c], :e => [:b, :c], :f => [:b, :c]}
    xp_names = {}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, names, edges)

    # cumulative (names are ignored because aren't cumulative)
    graph, names = bs_add_edges({}, {}, {:c => :a})
    graph, names = bs_add_edges(graph, names, {:b => [:a]})
    graph, names = bs_add_edges(graph, names, {[:d, :e, :f] => [:b, :c]})
    xp_graph = {:c=>[:a], :b=>[:a], :d=>[:b, :c], :e=>[:b, :c], :f=>[:b, :c]}
    assert_equal [xp_graph, {}], [graph, names]

    # with named nodes
    graph = {} # graph is empty
    edges = {{:c => "Charlie"} => :a}
    names = {}
    xp_graph = {:c => [:a]}
    xp_names = {:c => "Charlie"}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, names, edges)

    # with named nodes, accumulating names
    graph = {} # graph is empty
    edges = {{:c => "Charlie"} => :a}
    names = {:z => "Zulu"} # kludge because it doesn't have an edge
    xp_graph = {:c => [:a]}
    xp_names = {:c => "Charlie", :z => "Zulu"}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, names, edges)

    graph = {}
    edges = {{:c => "Charlie"} => :a}
    names = {}
    xp_graph = {:c => [:a]}
    xp_names = {:c => "Charlie"}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, names, edges)

    graph = {:b => [:a]}
    edges = {{:c => "Charlie"} => :a}
    names = {}
    xp_graph = {:b => [:a], :c => [:a]}
    xp_names = {:c => "Charlie"}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, names, edges)

    # test normalizer
    normalizer = lambda {|x| x.next }

    graph = {:b => [:a]}
    edges = {{:c => "Charlie"} => :a}
    names = {}
    xp_graph = {:b => [:a], :d => [:b]}
    xp_names = {:d => "Charlie"}
    assert_equal [xp_graph, xp_names], bs_add_edges(graph, names, edges, normalizer)

  end

end


