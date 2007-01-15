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

  # Replace this with your real tests.
  def test_truth
    assert true
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
  
end
