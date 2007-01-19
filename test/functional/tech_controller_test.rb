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
  
  def test_new_encounter_display
    get(:new_encounter, 
        {},
        :user_id => users(:marc).id)
    
    assert_response :success
    assert_template "new_encounter"
  end
  
  def test_new_encounter_create
    assert 2, Encounter.count
  
    chest_pain = encounters(:chest_pain)
  
    get(:new_encounter,
        {:id => patients(:baxter).id},
        {:user_id => users(:marc).id})
        
    post(:new_encounter,
        {:encounter => {:date => chest_pain.date,
                        :patient_id => chest_pain.patient_id,
                        :indication => chest_pain.indication,
                        :findings => chest_pain.findings,
                        :impression => chest_pain.impression,
                        :encounter_type_id => chest_pain.encounter_type_id,
                        :provider_id => chest_pain.provider_id}},
        {:user_id => users(:marc).id})
        
    assert_response :redirect
    assert_redirected_to :action => :upload_image
    follow_redirect
    assert_template "upload_image"
    assert 3, Encounter.count    
  end
  
  def test_new_patient
  
    assert 2, Patient.count
  
    get(:new_patient,
        {},
        {:user_id => users(:marc).id})
    
    post(:new_patient,
        {:patient => {:given_name => "Evelyn",
                      :family_name => "Wasike",
                      :mtrh_rad_id => 12346,
                      :mrn_ampath => 5321,
                      :tribe_id => 2}},
        {:user_id => users(:marc).id})
    assert 3, Patient.count
    
  end
  
#  def test_upload_images
#    assert 1, Image.count
#    get(:upload_image,
#       {:id => encounters(:chest_pain)},
#       {:user_id => users(:marc).id})
#    
#    img = uploaded_jpeg("#{File.expand_path(RAILS_ROOT)}/test/fixtures/rails.jpg")
#    
#    post(:add_image,
#        {:image => {:file_data => img,
#                    :encounter_id => encounters(:chest_pain).id}},
#        {:user_id => users(:marc).id})
#
#    assert_redirected_to :action => "upload_image"
#    follow_redirect
#    assert_template "upload_image"
#    
#    assert 2, Image.count
#    
#    #Now, test removing the same image
#    
#    post(:remove_image,
#        {:id => 3},
#        {:user_id => users(:marc).id})
#        
#    assert 1, Image.count
#    
#  end
#  
#  # Helpers to simulate file uploads.  Stolen from: http://manuals.rubyonrails.com/read/chapter/28
#  
#  # get us an object that represents an uploaded file
#  def uploaded_file(path, content_type="application/octet-stream", filename=nil)
#    filename ||= File.basename(path)
#    t = Tempfile.new(filename)
#    FileUtils.copy_file(path, t.path)
#    (class << t; self; end;).class_eval do
#      alias local_path path
#      define_method(:original_filename) { filename }
#      define_method(:content_type) { content_type }
#    end
#    return t
#  end
#  
#  # a JPEG helper
#  def uploaded_jpeg(path, filename=nil)
#    uploaded_file(path, 'image/jpeg', filename)
#  end
#  
#  # a GIF helper
#  def uploaded_gif(path, filename=nil)
#    uploaded_file(path, 'image/gif', filename)
#  end
  
end
