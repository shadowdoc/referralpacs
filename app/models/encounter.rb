class Encounter < ActiveRecord::Base
  validates_presence_of :date
  belongs_to :patient
  belongs_to :encounter_type
  belongs_to :provider
  belongs_to :client
  has_many :images, :dependent => :delete_all
  has_many :observations, :dependent => :delete_all
  
  attr_protected :created_at, :created_by, :updated_at, :updated_by
  
  def self.find_range(start_date = Time.now.strftime("%y-%m-%d"), end_date = Time.now.strftime("%y-%m-%d"))
    #This method returns encounters between the given dates
    #If no dates are given, these default to today
    Encounter.find(:all, :conditions => ['date between ? and ?', start_date, end_date])
  end
  
  
  def save
    
    #TODO This is where the HL7 generation code should go
    #So that HL7 messages are automatically generated and
    #sent when an encounter is saved
    
    # Check to see if our encounter is reported, and if so make sure that we set that property
    
    if self.observations.length > 0 || self.impression != ""
      self.reported = true
    else
      self.reported = false
    end
    
    super
  end
  
end
