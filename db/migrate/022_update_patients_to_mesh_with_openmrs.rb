class UpdatePatientsToMeshWithOpenmrs < ActiveRecord::Migration
  def self.up
    add_column :patients, 'city_village', :string
    add_column :patients, 'state_province', :string
    add_column :patients, 'country', :string
  end

  def self.down
    remove_column :patients, 'city_village'
    remove_column :patients, 'state_province'
    remove_column :patients, 'country'
  end
end
