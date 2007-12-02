require File.dirname(__FILE__) + '/../test_helper'

class ConceptTest < Test::Unit::TestCase
  fixtures :concepts

  def setup
    @left_basilar = Concept.find 1
  end
    
  def test_concept_content
    
    # Make sure the concept object has the same content as the fixture.
    assert concepts(:concepts_048).name, @left_basilar.name
    assert concepts(:concepts_048).id, @left_basilar.id
    assert concepts(:concepts_048).description, @left_basilar.description
  end
  
  def test_concept_update
    
    assert "LEFT BASILAR", @left_basilar.name 
    @left_basilar.name = "LEFT_BASILAR"
    assert @left_basilar.save, @left_basilar.errors.full_messages.join("; ")
    @left_basilar.reload
    assert_equal "LEFT_BASILAR", @left_basilar.name
    
  end
  
  def test_concept_destroy
    
    @left_basilar.destroy
    assert_raise(ActiveRecord::RecordNotFound) {Concept.find @left_basilar.id}
    
  end
  
end