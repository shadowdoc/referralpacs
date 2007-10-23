class ChangeRemoveUsersPrivilegeToDeleteUsers < ActiveRecord::Migration
  def self.up
    rename_column :privileges, :remove_user, :delete_user
  end

  def self.down
    rename_column :privileges, :delete_user, :remove_user
  end
end