class CreatePrivileges < ActiveRecord::Migration
  def self.up
    create_table :privileges do |t|
      t.column "name", :string
      t.column "view_study", :bool
      t.column "add_study", :bool
      t.column "remove_study", :bool
      t.column "add_patient", :bool
      t.column "remove_patient", :bool
      t.column "add_user", :bool
      t.column "remove_user", :bool
    end
    
    add_column :users, "privilege_id", :integer
    
  end

  def self.down
    drop_table :privileges
    remove_column :users, "privilege_id"
  end
end
