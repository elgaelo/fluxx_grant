require 'test_helper'

class ReviewerPortalControllerTest < ActionController::TestCase

  def setup
    @user1 = User.make
    login_as @user1
    @reviewer_portal = ReviewerPortal.make
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reviewer_portals)
  end
  
  test "should get CSV index" do
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:reviewer_portals)
  end
  
  test "autocomplete" do
    lookup_instance = ReviewerPortal.make
    get :index, :name => lookup_instance.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(lookup_instance.id)
  end

  test "should confirm that name_exists" do
    get :index, :name => @reviewer_portal.name, :format => :autocomplete
    a = @response.body.de_json # try to deserialize the JSON to an array
    assert a.map{|elem| elem['value']}.include?(@reviewer_portal.id)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reviewer_portal" do
    assert_difference('ReviewerPortal.count') do
      post :create, :reviewer_portal => { :name => 'some random name for you' }
    end

    assert 201, @response.status
    assert @response.header["Location"] =~ /#{reviewer_portal_path(assigns(:reviewer_portal))}$/
  end

  test "should show reviewer_portal" do
    get :show, :id => @reviewer_portal.to_param
    assert_response :success
  end

  test "should show reviewer_portal with documents" do
    model_doc1 = ModelDocument.make(:documentable => @reviewer_portal)
    model_doc2 = ModelDocument.make(:documentable => @reviewer_portal)
    get :show, :id => @reviewer_portal.to_param
    assert_response :success
  end
  
  test "should show reviewer_portal with groups" do
    group = Group.make
    group_member1 = GroupMember.make :groupable => @reviewer_portal, :group => group
    group_member2 = GroupMember.make :groupable => @reviewer_portal, :group => group
    get :show, :id => @reviewer_portal.to_param
    assert_response :success
  end
  
  test "should show reviewer_portal with audits" do
    Audit.make :auditable_id => @reviewer_portal.to_param, :auditable_type => @reviewer_portal.class.name
    get :show, :id => @reviewer_portal.to_param
    assert_response :success
  end
  
  test "should show reviewer_portal audit" do
    get :show, :id => @reviewer_portal.to_param, :audit_id => @reviewer_portal.audits.first.to_param
    assert_response :success
  end
  
  test "should get edit" do
    get :edit, :id => @reviewer_portal.to_param
    assert_response :success
  end

  test "should not be allowed to edit if somebody else is editing" do
    @reviewer_portal.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    get :edit, :id => @reviewer_portal.to_param
    assert assigns(:not_editable)
  end

  test "should not be allowed to update if somebody else is editing" do
    @reviewer_portal.update_attributes :locked_until => (Time.now + 5.minutes), :locked_by_id => User.make.id
    put :update, :id => @reviewer_portal.to_param, :reviewer_portal => {}
    assert assigns(:not_editable)
  end

  test "should update reviewer_portal" do
    put :update, :id => @reviewer_portal.to_param, :reviewer_portal => {}
    assert flash[:info]
    
    assert 201, @response.status
    assert @response.header["Location"] =~ /#{reviewer_portal_path(assigns(:reviewer_portal))}$/
  end

  test "should destroy reviewer_portal" do
    delete :destroy, :id => @reviewer_portal.to_param
    assert_not_nil @reviewer_portal.reload().deleted_at 
  end
end
