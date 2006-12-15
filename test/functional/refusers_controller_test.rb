require File.dirname(__FILE__) + '/../test_helper'
require 'refusers_controller'

# Re-raise errors caught by the controller.
class RefusersController; def rescue_action(e) raise e end; end

class RefusersControllerTest < Test::Unit::TestCase
  fixtures :refusers

  def setup
    @controller = RefusersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:refusers)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:refusers)
    assert assigns(:refusers).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:refusers)
  end

  def test_create
    num_refusers = Refusers.count

    post :create, :refusers => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_refusers + 1, Refusers.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:refusers)
    assert assigns(:refusers).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Refusers.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Refusers.find(1)
    }
  end
end
