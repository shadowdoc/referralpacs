class Patient < ActiveRecord::Base

  def before_create  
    self.user_created = params[:id]
  end
  
end
