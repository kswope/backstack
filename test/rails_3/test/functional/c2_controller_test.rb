require 'test_helper'

class C2ControllerTest < ActionController::TestCase

  test "should get b" do
    get :b
    assert_response :success
  end

  test "should get c" do
    get :c
    assert_response :success
  end

end
