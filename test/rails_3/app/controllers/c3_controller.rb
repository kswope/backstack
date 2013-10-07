class C3Controller < ApplicationController

  backstack([{:d => "Delta"}, 
             {:e => "Echo"}, 
             {:f => "Foxtrot"}] => ["c2#b", "c2#c"])


  def d;
  end

  def e;
  end

  def f;
  end

end
