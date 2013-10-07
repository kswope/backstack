require 'test_helper'

class C1ControllerTest < ActionController::TestCase

  test "should get a" do
    get :a
    assert_response :success
  end

end
