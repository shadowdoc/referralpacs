require File.dirname(__FILE__) + '/../test_helper'
require 'patient_controller'

# Re-raise errors caught by the controller.
class PatientController; def rescue_action(e) raise e end; end

class PatientControllerTest < Test::Unit::TestCase
  
  fixtures :patients, :users
  
  def setup
    @controller = PatientController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end  
  
  def test_new_patient
  
    assert 2, Patient.count
  
    get(:new,
        {},
        {:user_id => users(:tech).id})
    
    post(:new,
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
  
    get(:edit,
        {:id => baxter},
        {:user_id => users(:marc)})
        
    assert :success
    
    post(:edit,
        {:id => baxter,
         :patient => {:given_name => "Buster"}},
        {:user_id => users(:marc)})
        
    assert :success
    
    buster = Patient.find(baxter.id)
    
    assert_equal "BUSTER", buster.given_name
    
  end

# TODO  
# These tests are here as stubs, as currently testing functional output of AJAX
# Is tricky.
  
#  def test_find_patients_mrn_ampath
#    baxter = patients(:baxter)
#    post(:find, 
#        {:patient => {'mrn_ampath' => baxter.mrn_ampath}},
#        {:user_id => users(:client).id})    
#        
#    assert nil, @flash
#  end
#  
#  def test_find_patients_bad_mrn_ampath
#    baxter = patients(:baxter)
#    post(:find, 
#        {:patient => {'mrn_ampath' => 62}},
#        {:user_id => users(:client).id})    
#  end
#  
#  def test_find_patients_mtrh_rad_id
#
#  end
#  
#  def test_find_patients_bad_mtrh_rad_id
#  
#  end

  
end
