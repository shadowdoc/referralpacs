require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @user = User.find 1
  end
  
  def test_create
    marc = users(:marc)
    assert_kind_of User, @user
    assert_equal marc.id, @user.id
    assert_equal marc.name, @user.name
    assert_equal marc.email, @user.email
    assert_equal marc.hashed_password, @user.hashed_password
    assert_equal marc.privilege_id, @user.privilege_id
  end
  
  def test_update
    marc = users(:marc)
    assert_equal marc.name, @user.name
    @user.name = "Marc Kohli"
    @user.password = "crap"
    assert @user.save, @user.errors.full_messages.join("; ")
    @user.reload
    assert_equal "Marc Kohli", @user.name
    assert_equal User.hash_password('crap'), @user.hashed_password
    assert_equal marc.email, @user.email
  end
  
  def test_destroy
    @user = User.find 2
    @user.destroy
    assert_raise(ActiveRecord::RecordNotFound) {User.find @user.id}
  end
  
end
