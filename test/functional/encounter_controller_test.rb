require File.dirname(__FILE__) + '/../test_helper'
require 'encounter_controller'

# Re-raise errors caught by the controller.
class EncounterController; def rescue_action(e) raise e end; end

class EncounterControllerTest < Test::Unit::TestCase
  def setup
    @controller = EncounterController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_find_encounters_with_patient_id
    post(:find_encounters, 
         {:id => patients(:stanley).id}, 
         {:user_id => users(:admin).id})
    assert_response :success
    assert true, @show_new_encounter_link
    assert_template 'find_encounters'
  end
  
  def test_show_encounter
    put(:show_encounter, 
        {:id => encounters(:chest_pain).id}, 
        {:user_id => users(:client).id})
    assert_response :success
    assert_template 'show_encounter'
  end
  
  def test_new_encounter_display
    get(:new_encounter, 
        {},
        :user_id => users(:tech).id)
    
    assert_response :success
    assert_template "new_encounter"
  end
  
  def test_new_encounter_create
    assert 2, Encounter.count
  
    chest_pain = encounters(:chest_pain)
  
    get(:new_encounter,
        {:id => patients(:baxter).id},
        {:user_id => users(:tech).id})
        
    post(:new_encounter,
        {:encounter => {:date => chest_pain.date,
                        :patient_id => chest_pain.patient_id,
                        :indication => chest_pain.indication,
                        :findings => chest_pain.findings,
                        :impression => chest_pain.impression,
                        :encounter_type_id => chest_pain.encounter_type_id,
                        :provider_id => chest_pain.provider_id}},
        {:user_id => users(:tech).id})
        
    assert_response :redirect
    assert_redirected_to :action => :upload_image
    follow_redirect
    assert_template "upload_image"
    
    assert 3, Encounter.count    
  end
  
  
end
