class AddModifyPrivileges < ActiveRecord::Migration
  def self.up
    add_column :privileges, 'modify_patient', :boolean
    add_column :privileges, 'modify_encounter', :boolean
    add_column :privileges, 'merge_patients', :boolean
  end

  def self.down
    remove_column :privileges, 'modify_patient'
    remove_column :privileges, 'modify_encounter'
    remove_column :privileges, 'merge_patients'
  end
end
