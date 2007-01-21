require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  
  fixtures :users, :encounters, :patients, :encounter_types, :privileges

  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
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
    
    assert "Buster", buster.given_name
    
  end
  
  def test_merge_patients
  
  end
  
  def test_add_user
    
    assert User.count, 5
  
    get(:add_user,
      {},
      {:user_id => users(:marc)})
    
    post(:add_user,
        {:user => {:name => "Wasike",
                   :email => "wasike@email.com",
                   :privilege_id => 1,
                   :password => "password"}},
        {:user_id => users(:marc)})
                  
    assert_redirected_to(:action => :list_users)
    assert "User wasike@email.com created.", flash[:notice]
    
    follow_redirect
    assert_template "list_users"
    
    assert User.count, 6
    
  end
  
  def test_delete_user
    
    assert User.count, 5
  
    post(:delete_user,
        {:id => 5},
        {:user_id => users(:marc)})
        
    assert User.count, 4
  
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
          :user => {:name => "marcus",
                    :email => "junk@email.com",
                    :password => "password"}},
         {:user_id => users(:marc)})
         
    assert_redirected_to(:action => "list_users")
    follow_redirect
    assert_template "list_users"
    
    marcus = User.find(marc.id)
    
    assert "marcus", marcus.name
  end
  
end
