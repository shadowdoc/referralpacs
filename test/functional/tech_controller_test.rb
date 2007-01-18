require File.dirname(__FILE__) + '/../test_helper'
require 'tech_controller'

# Re-raise errors caught by the controller.
class TechController; def rescue_action(e) raise e end; end

class TechControllerTest < Test::Unit::TestCase

  fixtures :users, :encounters, :patients, :encounter_types
  
  def setup
    @controller = TechController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_find_encounters_recent
    get(:find_encounters, {}, {:user_id => users(:marc).id})
    
    assert_response :success
    assert_template 'find_encounters'
    assert_select "tr#encounter", :count => 2
  end
  
  def test_find_encounters_with_patient_id
    put(:find_encounters, {:id => patients(:stanley).id}, {:user_id => users(:marc).id})
    assert_response :success
    assert true, @show_new_encounter_link
    assert_template 'find_encounters'
    assert_select "tr#encounter", :count => patients(:stanley).encounters.count
  end
  
  def test_show_encounter_new
    put(:show_encounter, {:encounter => {:patient_id => patients(:baxter).id }}, {:user_id => users(:marc).id})
    assert_response :success
    assert_template 'show_encounter'
  end
  
  def test_show_encounter_old
    get(:show_encounter, {:id => encounters(:chest_pain).id}, {:user_id => users(:marc).id })
    assert_response :success
    assert_template 'readonly_encounter'
  end
  
  def test_find_patients_mrn_ampath
    baxter = patients(:baxter)
    post(:find_patients, 
        {:search => {'search_criteria' => baxter.mrn_ampath, 'identifier_type' => 'mrn_ampath'}},
        {:user_id => users(:marc).id})
    
    assert_response :redirect
    assert_redirected_to :action => 'find_encounters', :id => baxter.id
  end
  
  def test_find_patients_bad_mrn_ampath
      post(:find_patients, 
      {:search => {'search_criteria' => 93, 'identifier_type' => 'mrn_ampath'}},
      {:user_id => users(:marc).id})
      
      assert_response :success
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
  end
  
  def test_find_patients_bad_mtrh_rad_id
    post(:find_patients, 
    {:search => {'search_criteria' => 92, 'identifier_type' => 'mtrh_rad_id'}},
    {:user_id => users(:marc).id})
    
    assert_response :success
    assert_template "find_patients"
    assert flash[:notice] = "No such patient: mtrh_rad_id = 92.  Click New Patient"
  end
  
  def test_new_encounter 
      
  end
