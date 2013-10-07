class C4Controller < ApplicationController

  # Regression test, names weren't working right when backstack was
  # called multiple times, so lets do that here.
  backstack({:g => "Golf"} => ["c3#d", "c3#e", "c3#f"])
  backstack({:h => "Hotel"} => ["c3#d", "c3#e", "c3#f"])
  backstack({:i => "India"} => ["c3#d", "c3#e", "c3#f"])
  backstack({:j => "Juliet"} => ["c3#d", "c3#e", "c3#f"])

  def g;
  end

  def h;
  end

  def i;
  end

  def j;
  end

end
