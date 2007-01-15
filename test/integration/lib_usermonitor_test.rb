require "#{File.dirname(__FILE__)}/../test_helper"

class LibUsermonitorTest < ActionController::IntegrationTest
  fixtures :users
  
  def test_created_by
    post 'login/login', :user => {:email => users(:marc).email, :password => "password"}

    get 'patient/edit/1'
    assert :success
    assert_template 'patient/edit'
    assert Thread.current['user'], users(:marc)
  end
  
end
