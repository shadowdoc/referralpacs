class EncounterType < ActiveRecord::Base
  belongs_to :encounter
  validates_presence_of :name, :modality
end
