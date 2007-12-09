require File.dirname(__FILE__) + '/../test_helper'
require 'encounter_controller'

# Re-raise errors caught by the controller.
class EncounterController; def rescue_action(e) raise e end; end

class EncounterControllerTest < Test::Unit::TestCase
  
  fixtures :patients, :users, :encounters, :encounter_types, :privileges
  
  def setup
    @controller = EncounterController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_find_encounters_with_patient_id
    
    post(:find, 
         {:id => patients(:stanley).id}, 
         {:user_id => users(:admin).id})
         
    assert_response :success
    
    assert true, @show_new_encounter_link
    
    assert_template 'find'
    
  end
  
  def test_show_encounter
    get(:show, 
        {:id => encounters(:chest_pain).id}, 
        {:user_id => users(:client).id})
    assert_response :success
    
    assert_template 'show'
  end
    
  def test_new_encounter_create
    assert_equal 2, Encounter.count

    # We're going to use a valid encounter already in a fixture.
    chest_pain = encounters(:chest_pain)
        
    post(:edit,
         {:encounter => {:date => chest_pain.date,
                         :patient_id => chest_pain.patient_id,
                         :indication => chest_pain.indication,
                         :findings => chest_pain.findings,
                         :impression => chest_pain.impression,
                         :encounter_type_id => chest_pain.encounter_type_id,
                         :provider_id => chest_pain.provider_id}},
         {:user_id => users(:admin).id})
        
    assert_equal 3, Encounter.count    
  end
  
  def test_edit_encounter
    
    chest_pain = encounters(:chest_pain)
    
    assert_equal "Chest pain", chest_pain.indication
    
    get(:edit, 
        {:id => chest_pain},
        {:user_id => users(:admin).id})
        
    assert :success
    
    post(:edit,
        {:id => chest_pain, 
         :encounter => {:indication => "Chest pain and SOB"}},
        {:user_id => users(:admin).id})
        
    assert :success
    
    chest_pain.reload
    
    assert_equal "Chest pain and SOB", chest_pain.indication
    
  end
  
end
