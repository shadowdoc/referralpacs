require File.dirname(__FILE__) + '/../test_helper'
require 'tech_controller'

# Re-raise errors caught by the controller.
class TechController; def rescue_action(e) raise e end; end

class TechControllerTest < Test::Unit::TestCase

  fixtures :users, :encounters, :patients
  
  def setup
    @controller = TechController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
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
