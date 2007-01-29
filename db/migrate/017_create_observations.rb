class CreateObservations < ActiveRecord::Migration
  def self.up
    create_table :observations do |t|
      t.column :encounter_id, :integer
      t.column :concept_id, :integer
      t.column :patient_id, :integer
      t.column :value_numeric, :float
      t.column :value_concept_id, :integer
      t.column :value_boolean, :boolean
      t.column :created_by, :integer
      t.column :created_at, :datetime
      t.column :updated_by, :integer
      t.column :updated_at, :datetime      
    end
  end

  def self.down
    drop_table :observations
  end
end