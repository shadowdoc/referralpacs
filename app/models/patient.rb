class Patient < ActiveRecord::Base
  has_many :encounters
  belongs_to :tribe
  
  validates_presence_of :given_name, :family_name, :mtrh_rad_id
  validates_uniqueness_of :mrn_ampath, :mtrh_rad_id
  
  before_save :lowercase
  
  #Provide a concatenated name for cleaner display.
  def full_name
    given_name + " " + family_name
  end
  
  def lowercase
    write_attribute :family_name, family_name.camelize
    write_attribute :given_name, given_name.camelize
  end
   
end
