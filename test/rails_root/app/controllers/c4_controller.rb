class C4Controller < ApplicationController

  backstack([[:g => "Golf"], 
             [:h => "Hotel"],
             [:i => "India"],
             [:j => "Juliet"]] => ["c3#d", "c3#e", "c3#f"])

  def g
  end

  def h
  end

  def i
  end

  def j
  end

end
