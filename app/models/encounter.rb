class Encounter < ActiveRecord::Base
  validates_presence_of :encounter_date, :study_id, :requester_id, :indication, :findings, :impression, :radiologist_id
  belongs_to :patient
end
