class AddXrayIdToEncounter < ActiveRecord::Migration
  def self.up
    add_column :encounters, :xray_id, :integer
  end

  def self.down
    remove_column :encounters, :xray_id
  end
end
