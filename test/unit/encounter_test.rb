require File.dirname(__FILE__) + '/../test_helper'

class EncounterTest < Test::Unit::TestCase
  fixtures :encounters

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_invalid_with_empty_attributes
    encounter = Encounter.new
    assert !encounter.valid?
    
  end
end
