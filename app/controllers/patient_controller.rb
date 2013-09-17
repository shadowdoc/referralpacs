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
        @encounters = Encounter.includes(:location, :patient).where('date LIKE ?', '%' + params[:encounter][:date] + '%')

        @encounters.each do |enc| 

          if enc.location.name == params[:encounter][:location]
            @patients << enc.patient 
          end
          
        end
        
      end
      
      if @patients.nil? && params[:encounter][:date] != ""
        # If we haven't found any patients and someone listed a date
        @encounters = Encounter.includes(:patient).where('date LIKE ?', '%' + params[:encounter][:date] + '%')
        @patients = Array.new()
        @encounters.each { |enc| @patients << enc.patient }       
        @patients.uniq!
      end
      
      if @patient.nil? && params[:encounter][:location]!= ""
        # if we havent found any patients and someome listed by location
        loc = Location.where('name LIKE ?','%' + params[:encounter][:location] + '%').first
        @encounters = loc.encounters
        @patients   = Array.new()
        @encounters.each { |enc| @patients << enc.patient }       
        @patients.uniq!
      end
      
      # Our patients arrays should be set now.  If not, no one was found.
      
      if @patients.nil? || @patients.empty?
          
           @response_string = ""
           
           if OPENMRS_URL_BASE && $openmrs_down
             @response_string = "Connection with OpenMRS Server <i>#{OPENMRS_SERVER_NAME}</i> is down, please contact the administrator.<br/><br/>"
           end
           
           @response_string += "No patients found"

           render "find_error"

      else
         
        render "ajax_list_patients", :formats => [:js]
         
      end
    end
  end
  
  def new
    @all_tribes = Tribe.order("name ASC").all

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
    
    @all_tribes = Tribe.order("name ASC").all
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
  
end
