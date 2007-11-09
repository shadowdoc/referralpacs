require File.dirname(__FILE__) + '/../test_helper'
require 'dictionary_controller'

# Re-raise errors caught by the controller.
class DictionaryController; def rescue_action(e) raise e end; end

class DictionaryControllerTest < Test::Unit::TestCase
  
  fixtures :concepts, :answers
  
  def setup
    @controller = DictionaryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_population_of_concepts_for_lookup_array
    
    assert_nil @concepts
    
    get "concepts_for_lookup"
    
    assert :success
    
    # This should really test to see if the javascript is returned correctly
    
  end
  
  
  
end
