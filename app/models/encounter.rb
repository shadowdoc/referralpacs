class Encounter < ActiveRecord::Base
  validates_presence_of :date, :indication, :findings, :impression
  belongs_to :patient
  has_one :study_type
end
