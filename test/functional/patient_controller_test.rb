require File.dirname(__FILE__) + '/../test_helper'
require 'patient_controller'

# Re-raise errors caught by the controller.
class PatientController; def rescue_action(e) raise e end; end

class PatientControllerTest < Test::Unit::TestCase
  def setup
    @controller = PatientController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_find_patients_mrn_ampath
    baxter = patients(:baxter)
    post(:find_patients, 
        {:search => {'search_criteria' => baxter.mrn_ampath, 'identifier_type' => 'mrn_ampath'}},
        {:user_id => users(:client).id})
    
    assert_response :redirect
    assert_redirected_to :action => 'find_encounters', :id => baxter.id
    follow_redirect
    assert_template "find_encounters"
  end
  
  def test_find_patients_bad_mrn_ampath
      post(:find_patients, 
          {:search => {'search_criteria' => 93, 'identifier_type' => 'mrn_ampath'}},
          {:user_id => users(:client).id})

      assert :success
      assert_template "find_patients"
      assert flash[:notice] = "No such patient: mrn_ampath = 93.  Click New Patient"
  end
  
  def test_find_patients_mtrh_rad_id
    baxter = patients(:baxter)
    post(:find_patients, 
        {:search => {'search_criteria' => baxter.mtrh_rad_id, 'identifier_type' => 'mtrh_rad_id'}},
        {:user_id => users(:client).id})
    
    assert_response :redirect
    assert_redirected_to :action => 'find_encounters', :id => baxter.id
    follow_redirect
    assert_template "find_encounters"
  end
  
  def test_find_patients_bad_mtrh_rad_id
    post(:find_patients, 
        {:search => {'search_criteria' => 92, 'identifier_type' => 'mtrh_rad_id'}},
        {:user_id => users(:client).id})
    
    assert_response :success
    assert_template "find_patients"
    assert flash[:notice] = "No such patient: mtrh_rad_id = 92.  Click New Patient"
  end
  
  
  def test_new_patient
  
    assert 2, Patient.count
  
    get(:new_patient,
        {},
        {:user_id => users(:tech).id})
    
    post(:new_patient,
        {:patient => {:given_name => "Evelyn",
                      :family_name => "Wasike",
                      :mtrh_rad_id => 12346,
                      :mrn_ampath => 5321,
                      :tribe_id => 2}},
        {:user_id => users(:tech).id})
    assert 3, Patient.count
    
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

  
end
