class AddClientToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, 'contact', :string
    add_column :encounters, 'client_id', :integer
  end

  def self.down
    remove_column :users, 'contact'
  end
end
