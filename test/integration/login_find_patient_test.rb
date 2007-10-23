require "#{File.dirname(__FILE__)}/../test_helper"

class LoginFindPatientTest < ActionController::IntegrationTest

  fixtures :users, :patients

  def test_login_and_find_patient
    
    user = user_for_test
    
    user.login_failure
    user.login_success
  
  end

  def user_for_test
    
    open_session do |user|
      
      def user.login_failure
        assert_true session[:user_id].nil? # prove this session has no one logged in
        get "login/login"
        assert_response :success
        post "login/login", :email => "isuck", :password => "notgiven"
        assert_nil session[:user_id] # the user_id should not be set as our user does not exist
      end
      
      def user.login_success
        assert_nil session[:user_id] # prove this session has no one logged in
        get "login/login"
        assert_response :success
        post "login/login", :email => users[:marc].email, :password => users[:marc].password
        assert_not_nil session[:user_id]
        assert_response :redirect
        assert_redirected_to "patient/find"
        # The session is now logged in, we do not need to do this again.
      end
      
    end
    
  end

end
