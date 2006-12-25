class Patient < ActiveRecord::Base

  def created_by(user_id)
    self.user_created = user_id
  end
 
end
