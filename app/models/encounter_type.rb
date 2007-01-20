class EncounterType < ActiveRecord::Base
  has_many :encounters
  
  attr_protected :created_at, :created_by, :updated_at, :updated_by
  
end
