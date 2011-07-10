class AddStudyUidToEncounter < ActiveRecord::Migration
  def self.up
    add_column :encounters, :study_uid, :string
  end

  def self.down
    remove_column :encounters, :study_uid
  end
end
