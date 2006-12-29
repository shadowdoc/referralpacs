class AddBirthdateToPatient < ActiveRecord::Migration
  def self.up
    add_column :patients, :birthdate, :datetime
  end

  def self.down
    remove_column :patients, :birthdate
  end
end
