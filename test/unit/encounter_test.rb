require File.dirname(__FILE__) + '/../test_helper'

class EncounterTest < Test::Unit::TestCase
  fixtures :encounters

  def setup
    @encounter = Encounter.find 1
  end

  # Replace this with your real tests.
  def test_encounter_content
    assert_equal encounters(:right_pneumonia).id, @encounter.id
    assert_equal encounters(:right_pneumonia).patient_id, @encounter.patient_id
    assert_equal encounters(:right_pneumonia).date, @encounter.date
    assert_equal encounters(:right_pneumonia).indication, @encounter.indication
    assert_equal encounters(:right_pneumonia).findings, @encounter.findings
    assert_equal encounters(:right_pneumonia).impression, @encounter.impression
    assert_equal encounters(:right_pneumonia).encounter_type_id, @encounter.encounter_type_id
  end

  def test_encounter_update
    assert_equal encounters(:right_pneumonia).impression, @encounter.impression
    @encounter.impression = "Normal"
    assert @encounter.save, @encounter.errors.full_messages.join("; ")
    @encounter.reload
    assert_equal "Normal", @encounter.impression
  end
  
  def test_destroy
    @encounter.destroy
    assert_raise(ActiveRecord::RecordNotFound) {Encounter.find @encounter.id}
  end

end
