class Encounter < ActiveRecord::Base
  validates_presence_of :date, :indication, :findings, :impression
  belongs_to :patient
  belongs_to :encounter_type
  belongs_to :provider
  belongs_to :client
  has_many :images, :dependent => :delete_all
end