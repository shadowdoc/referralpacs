require File.dirname(__FILE__) + '/../test_helper'

class EncounterTypeTest < Test::Unit::TestCase
  fixtures :encounter_types
  
  def setup
    cxr = EncounterType.find 1
  end

  def test_encounter_type_content
    assert_equal encounter_types(:chest_xr).name, "Chest X-ray"    
    assert_equal encounter_types(:chest_xr).modality, "XR"
  end

  def test_encounter_type_crud
    
    # Create new encounter_type
    mri = EncounterType.new
    mri.name = "Brain MRI"
    mri.modality = "MR"
    
    # Save our new object to the database
    assert mri.save
    
    # Load our new object into a second variable
    assert_not_nil mri2 = EncounterType.find(mri.id)
    
    assert_equal mri, mri2
    
    # Modify
    mri.name = "Lumbar Spine MRI"
    assert mri.save
    
    # Destroy
    assert mri.destroy
    
  end
end
