# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  require "user"
  helper :date
  before_filter :set_current_user
  
#  TODO include SslRequirement
  
  ENCOUNTERS_PER_PAGE = 10
  
  def authorize_login
    unless session[:user_id] 
      flash[:notice] = "Please log in."
      redirect_to :controller => "login", :action => "login"
    end
  end
  
  def set_current_user
    unless session[:user_id].nil?
      Thread.current['user'] = User.find(session[:user_id])
    end
  end
  
  def hl7_msh
    # This code was devised to follow the description of an HL7 message listed here:
    # http://openmrs.org/wiki/HL7
    
    # This is the Message Header (MSH segment)
    
    sending_facility = "REFPACS"
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    
    msh = HL7::Message::Segment::MSH.new
    msh.enc_chars = "^~\&"
    msh.sending_app = sending_facility
    msh.sending_facility = "MTRH Radiology"
    msh.recv_app = "HL7LISTENER"
    msh.recv_facility = "AMRS"
    msh.time = timestamp
    msh.message_type = "ORU^RO1"
    msh.message_control_id = sending_facility + timestamp
    msh.processing_id = rand(10000).to_s
    msh.version_id = "2.5"
    msh.seq = 1
    
    return msh
  end

end