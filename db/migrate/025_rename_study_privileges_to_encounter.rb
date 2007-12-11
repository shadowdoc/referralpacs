class RenameStudyPrivilegesToEncounter < ActiveRecord::Migration
  def self.up
    rename_column :privileges, :add_study, :add_encounter
    rename_column :privileges, :remove_study, :delete_encounter
  end

  def self.down
    rename_column :privileges, :add_encounter, :add_study
    rename_column :privileges, :delete_encounter, :remove_study
  end
end
