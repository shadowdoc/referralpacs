# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  def redirect_to_encounters
    flash[:notice] = msg if msg
    redirect_to(:controller => 'admin', :action => 'list')
  end

end