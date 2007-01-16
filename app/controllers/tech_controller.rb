class TechController < ApplicationController

  before_filter :authorize_login
  ENCOUNTERS_PER_PAGE = 10
  layout "tech"

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

  def new_patient
    @patient = Patient.new()
  end

  def find_encounters
    # This controller will return a list of encounters, which may or may not be patient specific.
 
    if params[:id]
      @patient = Patient.find(params[:id])
      @encounter_pages, @encounters = paginate :encounters, :conditions => ["patient_id = ?", params[:id]], :per_page => ENCOUNTERS_PER_PAGE
      @show_new_encounter_link = true
    else
      @encounter_pages, @encounters = paginate :encounters, :per_page => ENCOUNTERS_PER_PAGE
    end
  end

  def show_encounter
    # This method must be called with a PUT, including params[:encounter]
    # if a new encounter is desired.
    # 
    # Technologists will not be able to edit existing encounters
    if params[:id] && @encounter = Encounter.find(params[:id])
      render :action => 'readonly_encounter'
    else
      @encounter = Encounter.new(params[:encounter])
    end
  end

  def upload_image
    
  end
  
  def remove_image
  end
end
