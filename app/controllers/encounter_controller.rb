class EncounterController < ApplicationController
  layout "ref"
  before_filter :authorize_login
  before_filter :security, :except => [:find, :show] # make sure to check permission for all except find and show
  
  protected
  def security
    # This method is called before data modifying actions to make sure the user 
    # has the ability to modify encounters
    @current_user = User.find(session[:user_id])
    
    unless @current_user.privilege.modify_encounter
      flash[:notice] = "Not enough privilege to modify encounter."
      return(redirect_to :controller => "patient", :action => "find")
    end 
  end

  public
  def find
    #TODO Install will_paginate plugin and restore pagination.  
    
    # This controller will return a list of encounters, which may or may not be patient specific.
    # If given an ID, the encounters will be for that patient.
 
#    if params[:id]
      @patient = Patient.find(params[:id])
      @encounters = @patient.encounters
      @current_user = User.find(session[:user_id])
#    else
#      @encounters = Encounter.find(:all)
#    end
#    
  end

  def details
    @encounter = Encounter.find(params[:id])
    @observation = Observation.new(:encounter_id => @encounter.id)
  end
  
  def edit
  
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
  
  def new

    # Given a patient.id from the params, this creates a new encounter object and returns
    # it to the view for manipulation.
  
    @patient = Patient.find(params[:id])
    @encounter = Encounter.new()  
    @encounter.patient_id = @patient.id
    @observation = Observation.new(:encounter_id => @encounter.id, :patient_id => @encounter.patient.id)
    
  end
  
  def delete
    
    # This method will permenantly delete an encounter
    
    @id = params[:encounter_id] 
    @encounter = Encounter.find(params[:id])
    @patient = @encounter.patient
    begin 
      @encounter.destroy
      flash[:notice] = "Encounter deleted."
    rescue
      flash[:notice] = "Could not delete encounter."
    end 
    redirect_to :action => "find", :id => @patient.id
    
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
  
  def statistics

    @patients = Patient.find(:all)

    if request.get?
      @start_date = Time.now.strftime("%Y-%m-%d")
      @end_date = @start_date
      @encounters_during_range = Encounter.find_range
    else
      @start_date = params[:report][:start_date]
      @end_date = params[:report][:end_date]
      @encounters_during_range = Encounter.find_range(params[:report][:start_date], params[:report][:end_date])
    end
    
    @reports_during_range = 0
    for enc in @encounters_during_range
      if enc.observations.length > 0 
        @reports_during_range += 1
      end
    end
  end

end
