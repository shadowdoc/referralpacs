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
    
    @patients = nil
  
    if request.post?
      
      # We first search based on patient demographics supplied by the user.

      @patients = Patient.search(params)

      if @patients.nil? && params[:encounter][:date] != "" && params[:encounter][:location] != ""
        # if we haven't found any patients and someone listed by date and location
        @encounters = Encounter.find(:all,:conditions => ['date LIKE ?', '%' + params[:encounter][:date] + '%']) 
        @encounters.each do |enc| 
        
          if enc.location.name == params[:encounter][:location]
            @patients << enc.patient 
          end
          
        end
        
      end
      
      if @patients.nil? && params[:encounter][:date] != ""
        # If we haven't found any patients and someone listed a date
        @encounters = Encounter.find(:all, :conditions => ['date LIKE ?', '%' + params[:encounter][:date] + '%'])
        @patients = Array.new()
        @encounters.each { |enc| @patients << enc.patient }       
        @patients.uniq!
      end
      
      if @patient.nil? && params[:encounter][:location]!= ""
        # if we havent found any patients and someome listed by location
        loc = Location.find(:first, :conditions => ['name LIKE ?','%' + params[:encounter][:location] + '%'])
        @encounters = loc.encounters
        @patients   = Array.new()
        @encounters.each { |enc| @patients << enc.patient }       
        @patients.uniq!
      end
      
      # Our patients arrays should be set now.  If not, no one was found.
      
      if @patients.nil? || @patients.empty?

         render :update do |page|

           #TODO Shouldn't this be in an RJS template?
           
           response_string = ""
           
           if $openmrs_down
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
          redirect_to :action => "find"
      else
          flash[:notice] = "Error saving patient."
      end

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
  
  def unreported
    
    @encounters = Encounter.find(:all, :conditions => ['reported = ?', false])
    @patients = []
    @encounters.each { |enc| @patients << enc.patient }
    @patients.uniq!
    
    render :partial => "list_patients"
  end
  
end
