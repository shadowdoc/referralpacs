# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  before_filter :set_current_user
  ENCOUNTERS_PER_PAGE = 10

  def redirect_to_encounters
    redirect_to(:controller => 'admin', :action => 'list')
  end
  
  def authorize_login
    unless session[:user_id] 
      flash[:notice] = "Please log in."
      redirect_to(:controller => "login", :action => "login")
    end
  end
  
  def set_current_user
    unless session[:user_id].nil?
      Thread.current['user'] = User.find(session[:user_id])
    end
  end
  
  def find_encounters
    # This controller will return a list of encounters, which may or may not be patient specific.
 
    if params[:id]
      @patient = Patient.find(params[:id])
      @encounter_pages, @encounters = paginate :encounters, :conditions => ["patient_id = ?", params[:id]], :per_page => ENCOUNTERS_PER_PAGE
    else
      @encounter_pages, @encounters = paginate :encounters, :per_page => ENCOUNTERS_PER_PAGE
    end
  end
  
  def find_patients
  
    if request.post?
      search_hash = params[:search]
      search_criteria = search_hash['search_criteria']

      case search_hash['identifier_type']
        when 'name'
          @patients = Patient.find(:all, :conditions => ["given_name = ? OR family_name = ?", search_criteria, search_criteria], :limit => 10)
        when 'mrn_ampath'
          @patient = Patient.find(:first, :conditions => ['mrn_ampath = ?', search_criteria])
          if @patient
            redirect_to(:action => :find_encounters, :id => @patient.id)
          else
            flash[:notice] = "No such patient: mrn_ampath = #{search_criteria}.  Click New Patient"
          end
        when 'mtrh_rad_id'
          @patient = Patient.find(:first, :conditions => ['mtrh_rad_id = ?', search_criteria])
          if @patient
            redirect_to(:action => :find_encounters, :id => @patient.id)
          else
            flash[:notice] = "No such patient: mtrh_rad_id = #{search_criteria}.  Click New Patient"
          end
      end
      
    end
  end
  
  def show_encounter
    @encounter = Encounter.find(params[:id])
  end
  
end