class Patient < ActiveRecord::Base
  has_many :encounters
  belongs_to :tribe
  
  validates_presence_of :given_name, :family_name
  validates_uniqueness_of :mtrh_rad_id
  
  validates_uniqueness_of :mrn_ampath, 
                          :if => Proc.new {|mrn_ampath| mrn_ampath.nil?}
  
  before_save :uppercase
  
  #Provide a concatenated name for cleaner display.
  def full_name
    unless self.given_name.nil? || self.family_name.nil?
      self.given_name + " " + self.family_name
    end
  end
  
  def birthdate_formatted
    self.birthdate.strftime("%d %b %Y") unless birthdate.nil?
  end
  
  def uppercase
    write_attribute :family_name, family_name.upcase
    write_attribute :given_name, given_name.upcase
  end
   
end
