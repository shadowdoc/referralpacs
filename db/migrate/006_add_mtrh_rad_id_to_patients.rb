class AddMtrhRadIdToPatients < ActiveRecord::Migration
  def self.up
    add_column :patients, :mtrh_rad_id, :integer
  end

  def self.down
    remove_column :patients, :mtrh_rad_id
  end
end
