class Answer < ActiveRecord::Base
  belongs_to :concept
  belongs_to :concept,
             :foreign_key => "answer_id"
end