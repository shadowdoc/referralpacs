require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @user = User.find 1
  end
  
  def test_create
    admin = users(:admin)
    assert_kind_of User, @user
    assert_equal admin.id, @user.id
    assert_equal admin.given_name, @user.given_name
    assert_equal admin.family_name, @user.family_name
    assert_equal admin.email, @user.email
    assert_equal admin.hashed_password, @user.hashed_password
    assert_equal admin.privilege_id, @user.privilege_id
  end
  
  def test_update
    admin = users(:admin)
    assert_equal admin.given_name, @user.given_name
    @user.given_name = "Marcus"
    @user.password = "crap"
    assert @user.save, @user.errors.full_messages.join("; ")
    @user.reload
    assert_equal "Marcus", @user.given_name
    assert_equal User.hash_password('crap'), @user.hashed_password
    assert_equal admin.email, @user.email
  end
  
  def test_destroy
    @user = User.find 2
    @user.destroy
    assert_raise(ActiveRecord::RecordNotFound) {User.find @user.id}
  end
  
end
