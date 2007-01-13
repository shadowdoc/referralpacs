class TechController < ApplicationController

  before_filter :authorize_login

  def find_patients
  end

  def new_patient
    @patient = Patient.new()
  end

  def find_encounters
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
