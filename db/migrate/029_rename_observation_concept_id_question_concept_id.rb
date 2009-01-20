class RenameObservationConceptIdQuestionConceptId < ActiveRecord::Migration
  def self.up
    rename_column :observations, :concept_id, :question_concept_id
  end

  def self.down
    rename_column :observations, :question_concept_id, :concept_id
  end
end
