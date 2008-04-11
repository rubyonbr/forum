require File.dirname(__FILE__) + '/../test_helper'
require 'aggregator_controller'

# Re-raise errors caught by the controller.
class AggregatorController; def rescue_action(e) raise e end; end

class AggregatorControllerTest < Test::Unit::TestCase
  def setup
    @controller = AggregatorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
