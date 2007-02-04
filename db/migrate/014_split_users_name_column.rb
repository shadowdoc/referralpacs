class SplitUsersNameColumn < ActiveRecord::Migration
  def self.up
    rename_column :users, "name", "given_name"
    add_column :users, "family_name", :string
  end

  def self.down
    rename_column :users, "given_name", "name"
    remove_column :users, "family_name"
  end
end
