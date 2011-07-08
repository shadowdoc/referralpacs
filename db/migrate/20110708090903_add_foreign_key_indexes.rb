class AddForeignKeyIndexes < ActiveRecord::Migration
  # would like to add indexes to foreign key fields to improve performance.

  def self.up
    add_index(:encounters, :patient_id, :name => 'patient_id_ix')
    add_index(:images, :encounter_id, :name => 'encounter_id_ix')
    add_index(:observations, :encounter_id, :name => 'encounter_id_ix')
    add_index(:answers, :concept_id, :name => 'concept_id_ix')
    add_index(:answers, :answer_id, :name => 'answer_id_ix')
  end

  def self.down
    remove_index(:encounters,'patient_id_ix')
    remove_index(:images, 'encounter_id_ix')
    remove_index(:observations, 'encounter_id_ix')
    remove_index(:answers, 'concept_id_ix')
    remove_index(:answers, 'answer_id_ix')
  end

end
