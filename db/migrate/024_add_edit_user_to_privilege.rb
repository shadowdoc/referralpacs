class AddEditUserToPrivilege < ActiveRecord::Migration
  def self.up
    add_column :privileges, 'update_user', :boolean, :default => false
  end

  def self.down
    remove_column :privileges, 'update_user'
  end

end
