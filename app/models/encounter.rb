class Encounter < ActiveRecord::Base
  validates_presence_of :date, :indication, :findings, :impression
  belongs_to :patient
  acts_as_list :scope => "date"
  has_one :study_type
end
