class RemoveContactFromClients < ActiveRecord::Migration
  def self.up
    remove_column :users, :contact
  end

  def self.down
    add_column :users, :contact, :string
  end
end
