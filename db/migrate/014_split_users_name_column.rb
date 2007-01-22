class SplitUsersNameColumn < ActiveRecord::Migration
  def self.up
    rename_column :users, "name", "given_name"
    add_column :users, "family_name", :string
  end

  def self.down
    remove_column :users, "family_name"
    rename_column "given_name", "name"
  end
end
