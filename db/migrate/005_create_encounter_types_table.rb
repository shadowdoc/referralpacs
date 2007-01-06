class CreateEncounterTypesTable < ActiveRecord::Migration

  # Renamed study from prior form to name in this database.

  def self.up
    create_table :encounter_types do |t|
      t.column "name", :string
      t.column "modality", :string
      t.column "created_at", :datetime
      t.column "created_by", :integer
      t.column "modified_at", :datetime
      t.column "modified_by", :datetime
    end
  
  end

  def self.down
    drop_table :encounter_types
  end
end
