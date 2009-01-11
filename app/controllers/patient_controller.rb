class PatientController < ApplicationController
  layout "ref"
  before_filter :authorize_login # Make sure an authorized user is logged in.
  before_filter :security, :except => :find

  protected
  def security
    # This method is called before any method that
    # Modifies patient data
    current_user = User.find(session[:user_id])
    
    unless current_user.privilege.modify_patient
      flash[:notice] = "Not enough privilege to modify patients."
      return(redirect_to :action => "find")
    end
    
  end

  public
  def find
    # If the request is a get, there is nothing to do.
  
    # We'll use this in this method, and also in the view to make
    # sure the links are correct
    @current_user = User.find(session[:user_id])  
  
    if request.post?
      begin
        @patients = Patient.search(params).to_a
      rescue
        openmrs_down = true
        @patients = nil
      end
      
      
      
      if @patients.length == 0 && params[:encounter][:date] != ""
        # If we haven't found any patients and someone listed a date
        @encounters = Encounter.find(:all, :conditions => ['date LIKE ?', '%' + params[:encounter][:date] + '%'])
        @patients = Array.new()
        @encounters.each { |enc| @patients << enc.patient }       
        @patients.uniq!
      end

      # Our patients arrays should be set now.  If not, no one was found.
      
      if @patients.length == 0 || @patients.empty?

         render :update do |page|

           #TODO Shouldn't this be in an RJS template?
           #TODO Can the current user add patients?  If so, let's give them the opportunity.
           
           response_string = ""
           
           if openmrs_down
             response_string = "Connection with OpenMRS Server <i>#{$openmrs_server_name}</i> is down, please contact the administrator.<br/><br/>"
           end
           
           unless @current_user.privilege.add_patient
             response_string += "No patients found, please search again"
           else
             response_string += "No patients found. <br/><br/>" + link_to("New Patient", :controller => :patient, :action => :new)
           end

           page.replace_html "patient-list", response_string
           page.visual_effect :highlight, "patient-list"
           
           page.form.reset 'patient-form'
           
         end
         
       else
         
         render :partial => "ajax_list_patients"
         
      end
    end
  end
  
  def new
    @all_tribes = Tribe.find(:all, :order => "name ASC")
    if request.get?
      @patient = Patient.new()
    else
      @patient = Patient.new(params[:patient])
      if @patient.save
        flash[:notice] = 'Patient was successfully created.'
        redirect_to :controller => :encounter, :action => "find", :id => @patient.id
      else
        render :action => 'new'
      end
    end
  end
  
  def edit
    #TODO: Updating patient information is currently broken due to the date control.
    #Additionally, I think that the update_attributes() is a security risk.
    
    @all_tribes = Tribe.find(:all, :order => "name ASC")
    if request.get?
      @patient = Patient.find(params[:id])
    else
      @patient = Patient.find(params[:id])
      if @patient.update_attributes(params[:patient])
          flash[:notice] = "Saved #{@patient.full_name}"
      else
          flash[:notice] = "Error saving patient."
      end
      redirect_to :action => "find"
    end
  end
  
  def delete
    # It takes not only modify_patient, but also remove_patient privilege to delete
    
    current_user = User.find(session[:user_id])
    patient = Patient.find(params[:id])
    
    if current_user.privilege.remove_patient
      patient.destroy
    else
      flash[:notice] = "Not enough privilege to delete a patient"

    end
    redirect_to :action => "find"    
  end

  def hl7test
    
    msg = HL7::Message.new
    
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
    
    # Add the header to our message.
    msg << msh
    
    # Now we'll build on an PID (patient identifier)
    
    # Put in a dummy patient object for testing
    patient = Patient.find(params[:id])
    
    pid = patient.hl7_pid
        
    # Add the pid to our message
    msg << pid
    
    # Make a string from the message to display in the web browser for debug
    # purposes.
    @msg = msg.to_s
    
    # This outputs our message in a text file where mirth can read it
    File.open("c:/dev/mirth/inbound/ruby-test.txt", "w+") do |f|
      f << msg
    end
    
  end
  
  def unreported
    
    @encounters = Encounter.find(:all, :conditions => ['reported = ?', false])
    @patients = []
    @encounters.each { |enc| @patients << enc.patient }
    @patients.uniq!
    
    render :partial => "list_patients"
  end
  
end
