class TechController < ApplicationController

  before_filter :authorize_login
  ENCOUNTERS_PER_PAGE = 10

  def find_patients
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
