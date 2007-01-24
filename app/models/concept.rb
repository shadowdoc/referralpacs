class Concept < ActiveRecord::Base
  has_many :answers
  
  def before_save
    self.name = self.name.upcase
  end

end
