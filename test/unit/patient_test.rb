require File.dirname(__FILE__) + '/../test_helper'

class PatientTest < Test::Unit::TestCase
  fixtures :patients

  def setup
    @patient = Patient.find 1
  end
  
  def test_content
    assert_equal patients(:baxter).id, @patient.id
    assert_equal patients(:baxter).given_name, @patient.given_name
    assert_equal patients(:baxter).family_name, @patient.family_name
    assert_equal patients(:baxter).mtrh_rad_id, @patient.mtrh_rad_id
  end

  def test_full_name
    # full_name should return given_name + ' ' + family_name
    assert_equal patients(:baxter).given_name + ' ' + patients(:baxter).family_name, @patient.full_name
  end

  def test_patient_update
    assert_equal patients(:baxter).given_name, @patient.given_name
    @patient.mtrh_rad_id = 76532
    assert @patient.save
    @patient.reload
    assert_equal 76532, @patient.mtrh_rad_id
  end
  
  def test_destroy
    @patient.destroy
    assert_raise(ActiveRecord::RecordNotFound) {Patient.find @patient.id}
  end
  
end
