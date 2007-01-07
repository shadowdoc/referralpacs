require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @user = User.find 1
  end
  
  def test_create
    assert_kind_of User, @user
    assert_equal users(:marc).id, @user.id
    assert_equal users(:marc).name, @user.name
    assert_equal users(:marc).email, @user.email
    assert_equal users(:marc).hashed_password, @user.hashed_password
    assert_equal users(:marc).privilege_id, @user.privilege_id
  end
  
  def test_update
    assert_equal users(:marc).name, @user.name
    @user.name = "Marc Kohli"
    @user.password = "password"
    assert @user.save, @user.errors.full_messages.join("; ")
    @user.reload
    assert_equal "Marc Kohli", @user.name
    assert_equal "5f4dcc3b5aa765d61d8327deb882cf99", @user.hashed_password
    assert_equal users(:marc).email, @user.email
  end
  
  def test_destroy
    @user = User.find 2
    @user.destroy
    assert_raise(ActiveRecord::RecordNotFound) {User.find @user.id}
  end
  
  def test_hashed_password
    assert_equal "5f4dcc3b5aa765d61d8327deb882cf99", @user.hashed_password
    @user.password = "crap"
    assert @user.save, @user.errors.full_messages.join("; ")
    @user.reload
    assert_equal "4dd77ecaf88620f5da8967bbd91d9506", @user.hashed_password
    assert_equal nil, @user.password
  end
end
