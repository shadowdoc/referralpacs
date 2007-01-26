class Observation < ActiveRecord::Base
  belongs_to :encounter
  belongs_to :patient
end
