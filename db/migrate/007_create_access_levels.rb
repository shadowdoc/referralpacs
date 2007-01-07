class CreateAccessLevels < ActiveRecord::Migration
  def self.up
    create_table :access_levels do |t|
      t.column "name", :string
      t.column "view_study", :bool
      t.column "add_study", :bool
      t.column "remove_study", :bool
      t.column "add_patient", :bool
      t.column "remove_patient", :bool
      t.column "add_user", :bool
      t.column "remove_user", :bool
    end
  end

  def self.down
    drop_table :access_levels
  end
end
