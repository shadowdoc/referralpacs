require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase

  fixtures :users, :privileges

  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_default
    assert true   
  end
  
  def test_index
    get :index
    assert_equal "Please log in.", flash[:notice]
    assert_redirected_to(:controller => "login", :action=>"login")
  end
  
  def test_login
    get :login
    post :login, :user => {:email => users(:marc).email, :password => "password"}
    
    assert_redirected_to(:controller => "login", :action => "list_users")
  end
  
  def test_bad_login
    get :login
    post :login, :user => {:email => users(:marc).email, :password => "wrong"}
    
    assert :success
    assert_equal "Invalid user/password combination", flash[:notice]
    assert_template "login"
  end

end