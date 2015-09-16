class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :date
  before_filter :set_current_user
    
  # Make changes to the ruby-HL7 framework to address our needs
  # These fields are customizations for OpenMRS HL7 formatting
  HL7::Message::Segment::OBR.class_eval { add_field(:identifier, :idx => 4) }
  HL7::Message::Segment::ORU.class_eval { add_field(:order_control, :idx => 1) }
  HL7::Message::Segment::ORU.class_eval { add_field(:transaction_date_time, :idx => 9) }
  HL7::Message::Segment::ORU.class_eval { add_field(:entered_by, :idx => 10) }
  HL7::Message::Segment::OBX.class_eval { add_field(:time, :idx => 14)}

  def authorize_login
    unless session[:user_id]
      flash[:notice] = "Please log in."
      redirect_to :controller => "login", :action => "login"
    end
    @current_user = set_current_user
  end

  def set_current_user
    unless session[:user_id].nil?
      Thread.current['user'] = User.find(session[:user_id])
    end
  end

  def self.hl7_msh
    # This code was devised to follow the description of an HL7 message listed here:
    # http://openmrs.org/wiki/HL7

    # This is the Message Header (MSH segment)

    timestamp = Time.now.strftime("%Y%m%d%H%M%S")

    HL7::Message::Segment::MSH.class_eval { add_field(:message_profile, :idx => 18) }
    msh = HL7::Message::Segment::MSH.new
    msh.enc_chars = '^~\&'
    msh.sending_app = OPENMRS_SENDING_FACILITY
    msh.sending_facility = OPENMRS_SENDING_FACILITY
    msh.recv_app = "HL7LISTENER"
    msh.recv_facility = OPENMRS_RECV_FACILITY
    msh.time = timestamp
    msh.message_type = "ORU^R01"
    msh.message_control_id = OPENMRS_SENDING_FACILITY + timestamp
    msh.processing_id = 'P'
    msh.version_id = "2.5"
    msh.seq = 1
    msh.message_profile = '||1^AMRS.ELD.FORMID'

    return msh
  end
end
