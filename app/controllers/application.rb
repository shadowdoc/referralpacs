# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  def redirect_to_encounters
    redirect_to(:controller => 'admin', :action => 'list')
  end
  
  def authorize
    unless session[:user_id] 
      flash[:notice] = "Please log in."
      redirect_to(:controller => "login", :action => "login")
    end
  end

end