class Observation < ActiveRecord::Base
  belongs_to :patient
  belongs_to :encounter
  belongs_to :question_concept,
             :class_name => "Concept",
             :foreign_key => "question_concept_id"
  belongs_to :value_concept,
             :class_name => "Concept",
             :foreign_key => "value_concept_id"
end