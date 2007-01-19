require File.dirname(__FILE__) + '/../test_helper'
require 'client_controller'

# Re-raise errors caught by the controller.
class ClientController; def rescue_action(e) raise e end; end

class ClientControllerTest < Test::Unit::TestCase

  fixtures :users, :encounters, :patients, :encounter_types

  def setup
    @controller = ClientController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_find_encounters_with_patient_id
    put(:find_encounters, {:id => patients(:stanley).id}, {:user_id => users(:marc).id})
    assert_response :success
    assert true, @show_new_encounter_link
    assert_template 'find_encounters'
  end
  
  def test_show_encounter
    put(:show_encounter, {:id => encounters(:chest_pain).id}, {:user_id => users(:marc).id})
    assert_response :success
    assert_template 'show_encounter'
  end
  
  def test_find_patients_mrn_ampath
    baxter = patients(:baxter)
    post(:find_patients, 
        {:search => {'search_criteria' => baxter.mrn_ampath, 'identifier_type' => 'mrn_ampath'}},
        {:user_id => users(:marc).id})
    
    assert_response :redirect
    assert_redirected_to :action => 'find_encounters', :id => baxter.id
    follow_redirect
    assert_template "find_encounters"
  end
  
  def test_find_patients_bad_mrn_ampath
      post(:find_patients, 
          {:search => {'search_criteria' => 93, 'identifier_type' => 'mrn_ampath'}},
          {:user_id => users(:marc).id})

      assert :success
      assert_template "find_patients"
      assert flash[:notice] = "No such patient: mrn_ampath = 93.  Click New Patient"
  end
  
  def test_find_patients_mtrh_rad_id
    baxter = patients(:baxter)
    post(:find_patients, 
        {:search => {'search_criteria' => baxter.mtrh_rad_id, 'identifier_type' => 'mtrh_rad_id'}},
        {:user_id => users(:marc).id})
    
    assert_response :redirect
    assert_redirected_to :action => 'find_encounters', :id => baxter.id
    follow_redirect
    assert_template "find_encounters"
  end
  
  def test_find_patients_bad_mtrh_rad_id
    post(:find_patients, 
        {:search => {'search_criteria' => 92, 'identifier_type' => 'mtrh_rad_id'}},
        {:user_id => users(:marc).id})
    
    assert_response :success
    assert_template "find_patients"
    assert flash[:notice] = "No such patient: mtrh_rad_id = 92.  Click New Patient"
  end
    
end
