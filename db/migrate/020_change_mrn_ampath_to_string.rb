class ChangeMrnAmpathToString < ActiveRecord::Migration
  def self.up
    change_column :patients, :mrn_ampath, :string
  end

  def self.down
    change_column :patients, :mrn_ampath, :integer
  end
end
