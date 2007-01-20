class TechController < ApplicationController

  ENCOUNTERS_PER_PAGE = 10
  layout "ref"
  
  before_filter :authorize_login
  
#  verify :method => :post, :only => [ :upload_image, :remove_image],
#         :redirect_to => {:action => :find_patients}
  
  def index
    redirect_to :action => 'find_patients'
  end
  
end
