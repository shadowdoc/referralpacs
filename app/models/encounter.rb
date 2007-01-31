class Encounter < ActiveRecord::Base
  validates_presence_of :date
  belongs_to :patient
  belongs_to :encounter_type
  belongs_to :provider
  belongs_to :client
  has_many :images, :dependent => :delete_all
  has_many :observations, :dependent => :delete_all
  
  attr_protected :created_at, :created_by, :updated_at, :updated_by
  
end
