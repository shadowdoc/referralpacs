class CreateObservations < ActiveRecord::Migration
  def self.up
    create_table :observations do |t|
      t.column :encounter_id, :integer
      t.column :concept_id, :integer
      t.column :patient_id, :integer
      t.column :value_numeric, :float
      t.column :value_concept, :integer
    end
  end

  def self.down
    drop_table :observations
  end
end