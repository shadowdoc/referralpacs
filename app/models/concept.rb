class Concept < ActiveRecord::Base
  has_many :answers
  has_many :observations
  
  def before_save
    self.name = self.name.upcase
  end

end
