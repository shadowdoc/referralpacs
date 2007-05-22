require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase

  fixtures :users, :encounters, :patients, :encounter_types, :privileges

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
    
    assert_redirected_to(:controller => users(:marc).privilege.name)
  end
  
  def test_bad_login
    get :login
    post :login, :user => {:email => users(:marc).email, :password => "wrong"}
    
    assert :success
    assert_equal "Invalid user/password combination", flash[:notice]
    assert_template "login"
  end
  
    def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_edit_patient
    baxter = patients(:baxter)
  
    get(:edit_patient,
        {:id => baxter},
        {:user_id => users(:marc)})
        
    assert :success
    
    post(:edit_patient,
        {:id => baxter,
         :patient => {:given_name => "Buster"}},
        {:user_id => users(:marc)})
        
    assert :success
    assert_template "edit_patient"
    
    buster = Patient.find(baxter.id)
    
    assert_equal "Buster", buster.given_name
    
  end
  
  def test_merge_patients
  
  end
  
  def test_add_user
    
    assert_equal User.count, 5
  
    get(:add_user,
      {},
      {:user_id => users(:marc)})
    
    post(:add_user,
        {:user => {:given_name => "Evelyn",
                   :family_name => "Wasike",
                   :email => "wasike@email.com",
                   :privilege_id => 1,
                   :password => "password"}},
        {:user_id => users(:marc)})
                  
    assert_redirected_to(:action => :list_users)
    assert_equal "User wasike@email.com created.", flash[:notice]
    
    follow_redirect
    assert_template "list_users"
    
    assert_equal User.count, 6
    
  end
  
  def test_delete_user
    
    assert_equal User.count, 5
  
    post(:delete_user,
        {:id => 5},
        {:user_id => users(:marc)})
        
    assert_equal User.count, 4
  
  end
  
  def test_delete_user_non_admin
  
    assert_equal User.count, 5
  
    post(:delete_user,
        {:id => 5},
        {:user_id => users(:tech)})
        
    assert_equal User.count, 5
  
  end
  
  def test_list_users
    get(:list_users,
        {},
        {:user_id => users(:marc)})
        
    assert :success
    assert_template "list_users"
    
  end
  
  def test_edit_user
    marc = users(:marc)
    get(:edit_user,
        {:id => marc},
        {:user_id => users(:marc)})
        
    post(:update_user,
         {:id => marc.id, 
          :user => {:given_name => "marcus",
                    :family_name => "Kohli",
                    :email => "junk@email.com",
                    :password => "password"}},
         {:user_id => users(:marc)})
         
    assert_redirected_to(:action => "list_users")
    follow_redirect
    assert_template "list_users"
    
    marcus = User.find(marc.id)
    
    assert_equal "marcus", marcus.given_name
  end
  
  def test_list_providers
    get(:list_providers,
        {},
        {:user_id => users(:marc)})
        
    assert :success
    assert_template "list_providers"
  end
  
  def test_add_provider
    
    assert_equal 2, Provider.count
     
    get(:add_provider,
        {},
        {:user_id => users(:marc)})
        
    post(:add_provider,
         :provider => {:given_name => "Joseph", 
                       :family_name => "Abuya",
                       :email => "abuya@email.com",
                       :password => "password",
                       :privilege_id => 2,
                       :title => "MD"},
         :user_id => users(:marc))
    
    assert_redirected_to :action => "list_providers"
    follow_redirect
    
    assert_equal  "Provider abuya@email.com created.", flash[:notice]
    assert_template "list_providers"
    
    assert_equal 3, Provider.count
  end
  
  def test_edit_provider
    
    marc = users(:marc)
    
    get(:edit_provider,
        {:id => marc.id},
        {:user_id => users(:marc)})
     
    post(:edit_provider,
        {:provider => {:given_name => "marcus",
                       :family_name => "kohlius",
                       :password => "password"}, :id => marc.id},
         :user_id => users(:marc))
 
    assert_redirected_to :action => "list_providers"
    assert_equal "Provider #{marc.email} was successfully updated", flash[:notice]
    
    follow_redirect
    assert_template "list_providers"
         
  end

end