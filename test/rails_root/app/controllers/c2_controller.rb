class C2Controller < ApplicationController

  backstack [:b, :c] => "c1#a"

  def b
  end

  def c
  end

end
