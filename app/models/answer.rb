class Answer < ActiveRecord::Base
  belongs_to :concept
  belongs_to :concept,
             :foreign_key => "answer_id"

  attr_accessible :concept_id, :answer_id
end