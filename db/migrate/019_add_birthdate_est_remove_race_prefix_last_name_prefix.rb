class AddBirthdateEstRemoveRacePrefixLastNamePrefix < ActiveRecord::Migration
  def self.up
    remove_column :patients, :race
    remove_column :patients, :last_name_prefix
    remove_column :patients, :prefix
    add_column :patients, "birthdate_estimated", :boolean
  end

  def self.down
    add_column :patients, :race, :string
    add_column :patients, :last_name_prefix, :string
    add_column :patients, :prefix, :string
    remove_column :patients, :birthdate_estimated
  end
end
