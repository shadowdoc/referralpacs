require File.dirname(__FILE__) + '/../test_helper'
require 'dictionary_controller'

# Re-raise errors caught by the controller.
class DictionaryController; def rescue_action(e) raise e end; end

class DictionaryControllerTest < Test::Unit::TestCase
  def setup
    @controller = DictionaryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
