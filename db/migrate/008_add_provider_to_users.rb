class AddProviderToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, "type", :string
    add_column :users, "title", :string
    add_column :encounters, "provider_id", :integer
  end

  def self.down
    remove_column :users, "type"
    remove_column :users, "title"
    remove_column :encounters, "provider_id"
  end
end
