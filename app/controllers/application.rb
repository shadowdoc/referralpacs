# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  require "user"
  helper :date
  before_filter :set_current_user
  
#  include SslRequirement
  
  ENCOUNTERS_PER_PAGE = 10
  
  def authorize_login
    unless session[:user_id] 
      flash[:notice] = "Please log in."
      render :file => "login/login"
    end
    
  end
  
  def set_current_user
    unless session[:user_id].nil?
      Thread.current['user'] = User.find(session[:user_id])
    end
  end

end