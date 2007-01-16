class Patient < ActiveRecord::Base
  has_many :encounters
  
  validates_presence_of :given_name, :family_name
  validates_uniqueness_of :mrn_ampath, :mtrh_rad_id
  
  before_save :lowercase
  
  #Provide a concatenated name for cleaner display.
  def full_name
    given_name + " " + family_name
  end
  
  def lowercase
    family_name = family_name.camelize
    given_name = given_name.camelize
  end
   
end
