# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  before_filter :set_current_user

  def redirect_to_encounters
    redirect_to(:controller => 'admin', :action => 'list')
  end
  
  def authorize
    unless session[:user_id] 
      flash[:notice] = "Please log in."
      redirect_to(:controller => "login", :action => "login")
    end
  end
  
  def set_current_user
    id = session[:user_id] && nil
    if !id.nil? 
      Thread.current['user'] = User.find(id)
    end
  end
end