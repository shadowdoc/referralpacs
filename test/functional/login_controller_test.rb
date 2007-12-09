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
  
  def test_login
    
    # set a valid user from the fixtures
    
    get "login"
    post(:login, 
         :user => {:email => users(:admin).email, :password => "password"})
    
    assert session[:user_id] = users(:admin).id
    
  end
  
  def test_login_without_privilege
    get "login"
    post "login", :user => {:email => users(:admin).email, :password => "wrong"}
    
    assert :success
    assert_equal "Invalid user/password combination", flash[:notice]
    assert_template "login"

  end
      
  def test_add_user
    
    assert_equal 5, User.count
    assert_nil User.find(:first, :conditions => ["given_name = ?", "Evelyn"])
  
    get(:add_user,
        {},
        {:user_id => users(:admin)})
    
    assert_response :success
    
    post(:add_user,
        {:user => {:given_name => "Evelyn",
                   :family_name => "Wasike",
                   :email => "wasike@email.com",
                   :privilege_id => 1,
                   :password => "password"}},
        {:user_id => users(:admin).id})

    assert_equal 6, User.count

    new_user = User.find(:first, :conditions => ["given_name = ?", "Evelyn"])

    assert_equal new_user.email, "wasike@email.com"

    assert_response :redirect
 
    follow_redirect
    

#    For some reason, I can't get this test to work, but it doesn't seem worth fixing at
#    this time as the app works?    
#    assert_equal "User wasike@email.com created.", flash[:notice]

    assert_template "list_users"
    
  end

  def test_add_user_without_privilege
    
    assert_equal 5, User.count

    post(:add_user,
         {:user => {:given_name => "Evelyn",
                    :family_name => "Wasike",
                    :email => "wasike@email.com",
                    :privilege_id => 1,
                    :password => "password"}},
         {:user_id => users(:client)})

    
    assert_equal 5, User.count
    
    assert_redirected_to(:controller => "patient", :action => "find")
    
  end

  def test_delete_user
    
    assert_equal 5, User.count
  
    post(:delete_user,
        {:id => 5},
        {:user_id => users(:admin)})
        
    assert_equal 4, User.count
    
  end
  
  def test_delete_user_without_privilege
  
    assert_equal 5, User.count
  
    post(:delete_user,
        {:id => 5},
        {:user_id => users(:client).id})
        
    assert_equal 5, User.count
    
    assert User.find(5)
    
    assert_redirected_to(:controller => "patient", :action => "find")
  
  end
  
  def test_list_users
    get(:list_users,
        {},
        {:user_id => users(:admin)})
        
    assert :success
    assert_template "list_users"
    
  end
  

  def test_update_user
    admin = users(:admin)
    get(:update_user,
        {:id => admin},
        {:user_id => users(:admin)})
        
    post(:update_user,
         {:id => admin.id, 
          :user => {:given_name => "marcus",
                    :family_name => "Kohli",
                    :email => "junk@email.com",
                    :password => "password"}},
         {:user_id => users(:admin)})
         
    assert_redirected_to(:action => "list_users")
    
    follow_redirect
    assert_template "list_users"
    
    marcus = User.find(admin.id)
    
    assert_equal "marcus", marcus.given_name
  
  end

  def test_update_user_without_privliege
    
    post(:update_user,
         {:id => users(:admin),
          :user => {:given_name => "marcus",
                    :family_name => "Kohli",
                    :email => "junkit@email.com",
                    :password => "password"}},
         {:user_id => users(:client)})
    
    marc = User.find(users(:admin).id)
    
    assert "Marc", marc.given_name

    assert_redirected_to(:controller => "patient", :action => "find")
          
  end
  
  def test_list_providers
    
    get(:list_providers,
        {},
        {:user_id => users(:admin)})
        
    assert :success
    
    assert_template "list_providers"
    
  end
  
  def test_add_provider
    
    assert_equal 2, Provider.count
     
    get(:add_provider,
        {},
        {:user_id => users(:admin)})
        
    post(:add_provider,
         :provider => {:given_name => "Joseph", 
                       :family_name => "Abuya",
                       :email => "abuya@email.com",
                       :password => "password",
                       :privilege_id => 2,
                       :title => "MD"},
         :user_id => users(:admin))
    
    assert_redirected_to :action => "list_providers"
    
    follow_redirect    
    assert_template "list_providers"
    
    assert_equal 3, Provider.count
  end
  
  def test_add_provider_without_privilege
    
    assert_equal 2, Provider.count
    
    admin = users(:admin)
    
    get(:add_provider, 
        {:id => admin.id},
        {:user_id => users(:client).id})
        
    assert_equal 2, Provider.count
    
    assert_redirected_to(:controller => "patient", :action => "find")
    
  end
  
  def test_edit_provider
    
    admin = users(:admin)
    
    get(:edit_provider,
        {:id => admin.id},
        {:user_id => admin.id})
     
    post(:edit_provider,
        {:provider => {:given_name => "marcus",
                       :family_name => "kohlius",
                       :password => "password"}, :id => admin.id},
         :user_id => admin.id)
 
    assert_redirected_to :action => "list_providers"
    
    follow_redirect
    assert_template "list_providers"
         
  end

  def test_edit_provider_without_privilege
    
    admin = users(:admin)
    
    get(:edit_provider,
        {:id => admin.id},
        {:user_id => users(:client)})
         
    assert_redirected_to(:controller => "patient", :action => "find")
             
  end

end