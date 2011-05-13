require 'test_helper'

class LoisControllerTest < ActionController::TestCase

  def setup
#    @user1 = User.make
    login_as_user_with_role Program.grants_administrator_role_name
#    login_as @user1
    @loi = Loi.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lois)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:lois)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create loi" do
    assert_difference('Loi.count') do
      post :create, :loi => { :email => 'test@test.com', :applicant => 'Applicant', :organization_name => "Organization", :project_title => 'some random name for you' }
    end

    assert 200, @response.status
  end

  test "should show loi" do
    get :show, :id => @loi.to_param
    assert_response :success
  end

  test "should show loi with documents" do
    model_doc1 = ModelDocument.make(:documentable => @loi)
    model_doc2 = ModelDocument.make(:documentable => @loi)
    get :show, :id => @loi.to_param
    assert_response :success
  end
  
  test "should show loi with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @loi, :group => group
    group_member2 = GroupMember.make :groupable => @loi, :group => group
    get :show, :id => @loi.to_param
    assert_response :success
  end
  
  test "should show loi with audits" do
    Audit.make :auditable_id => @loi.to_param, :auditable_type => @loi.class.name
    get :show, :id => @loi.to_param
    assert_response :success
  end
  
  test "should show loi audit" do
    get :show, :id => @loi.to_param, :audit_id => @loi.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @loi.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @loi.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @loi.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @loi.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @loi.to_param, :loi => {}
    assert assigns(:not_editable)
  end

  test "should update loi" do
    put :update, :id => @loi.to_param, :loi => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{loi_path(assigns(:loi))}$/
  end

  test "should destroy loi" do
    delete :destroy, :id => @loi.to_param
    assert_not_nil @loi.reload().deleted_at 
  end
end
