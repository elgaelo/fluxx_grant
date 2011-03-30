require 'test_helper'

class ReviewerPortalControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end

end
