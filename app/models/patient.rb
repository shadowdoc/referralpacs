class Patient < ActiveRecord::Base
  has_many :encounters
  validates_presence_of :given_name, :family_name
  
  #Provide a concatenated name for cleaner display.

  def full_name
    given_name + " " + family_name
  end
  
end
