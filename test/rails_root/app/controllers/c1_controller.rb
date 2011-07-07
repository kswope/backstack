class C1Controller < ApplicationController

  backstack({:a => "Alpha"} => nil)

  def a; end

end
