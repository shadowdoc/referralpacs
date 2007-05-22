class EncounterController < ApplicationController


  def find_encounters
    # This controller will return a list of encounters, which may or may not be patient specific.
 
    if params[:id]
      @patient = Patient.find(params[:id])
      @encounter_pages, @encounters = paginate :encounters, :conditions => ["patient_id = ?", params[:id]], :per_page => ENCOUNTERS_PER_PAGE
    else
      @encounter_pages, @encounters = paginate :encounters, :per_page => ENCOUNTERS_PER_PAGE
    end
    
  end
  
  def show_encounter
    @encounter = Encounter.find(params[:id])
    @observation = Observation.new(:encounter_id => @encounter.id)
  end
  
  def edit_encounter
  
    # This routine either creates a new encounter if it's called without a parameter, or 
    # Saves changes to an edited encounter when called with an Encounter.id
  
    if params[:id].nil?
      @encounter = Encounter.new(params[:encounter])
      @encounter.save
    else
      @encounter = Encounter.find(params[:id])
      @encounter.update_attributes(params[:encounter])
      @encounter.save
    end
    render :partial => 'edit_encounter', :object => @encounter
  end
  
  def new_encounter
    
    # Given a patient.id from the params, this creates a new encounter.
  
    @patient = Patient.find(params[:id])
    @encounter = Encounter.new()  
    @encounter.patient_id = @patient.id
    @observation = Observation.new(:encounter_id => @encounter.id, :patient_id => @encounter.patient.id)
    
  end

  def add_observation
  
    # Adds an observation to an encounter.
    @id = params[:encounter_id]
    @encounter = Encounter.find(@id)
    @concept = Concept.find(:first, :conditions => ["name = ?", params[:concept_name]])
    @value_concept = Concept.find(:first, :conditions => ["name = ?", params[:value_concept_name]])
    @observation = Observation.new(:encounter_id => @encounter.id,
                                   :patient_id => @encounter.patient.id,
                                   :concept_id => @concept.id,
                                   :value_concept_id => @value_concept.id)
    @observation.save
    render :partial => "add_observation", :object => @observation
  end
  
  def remove_observation
  
    # Removes a specific observation from an encounter.
    @observation = Observation.find(params[:id])
    @observation.destroy
    render :update do |page|
        page.remove "observation-#{params[:id]}"
    end    
  end

end
