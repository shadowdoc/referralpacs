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
    
    # This controller will return a list of encounters, given a patient ID.
 
    @patient = Patient.find(params[:id])
    @encounters = @patient.encounters.sort! {|x, y| y.date <=> x.date }
    @current_user = User.find(session[:user_id])

    if @encounters.empty?
      flash[:notice] = "No encounters for #{@patient.full_name}"
    end
  
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

    if request.env['HTTP_REFERER'].include?("unreported")
      redirect_to :action => "unreported"
    else
      redirect_to :action => "find", :id => @patient.id     
    end

    
  end

  def add_observation
    
    # Adds an observation to an encounter.
    
    @id = params[:encounter_id]
    @encounter = Encounter.find(@id)
    question_concept = Concept.find(:first, :conditions => ["name = ?", params[:concept_name]])
    value_concept = Concept.find(:first, :conditions => ["name = ?", params[:value_concept_name]])
    @observation = Observation.new(:encounter_id => @encounter.id,
                                   :patient_id => @encounter.patient.id,
                                   :question_concept_id => question_concept.id,
                                   :value_concept_id => value_concept.id)
    @observation.save
    
    if @encounter.observations.length < 2
      # If there is only one observation, would should call the save method to make sure
      # that the reported status changes.
      @encounter.save    
    end
    
    
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
  
  def unreported
    
    @encounters = Encounter.find(:all, :conditions => ['reported = ?', false], :order => 'date ASC', :limit => 20)
    
    if @encounters.length == 0
      render :text => 'Congratulations - No unreported studies!', :layout => true
    end
    
  end
  
  def report
    # Process input from master form.
    
    @encounter = Encounter.find(params[:id])
    @patient = @encounter.patient
    
    if request.get?
      @observations = @encounter.observations
      
    end
    
    if request.post? 
      # We have a post request, let's process the record
      
      params.each_pair do |key, value|
        unless value == "none"  || value == "normal"
          unless ["id", "commit", "action", "controller"].include? key
            question_concept = Concept.find(:first, :conditions => ["name = ?", key.humanize.upcase])
            
            if question_concept.nil?
              raise "concept #{key.humanize.upcase} not found"
            end
            
            value_concept = Concept.find(:first, :conditions => ["name = ?", value.humanize.upcase])
            
            if value_concept.nil? 
              raise "value #{value.humanize.upcase} not found"
            end
            
            observation = Observation.new(:encounter_id => @encounter.id,
                                           :patient_id => @encounter.patient.id,
                                           :question_concept_id => question_concept.id,
                                           :value_concept_id => value_concept.id)
            observation.save
         
           end
        end 
      end
      
    end
    
    
  end
  
  def update_location
    @encounters = Encounter.find(:all)
    
    flash[:notice] = "Updating Encounters<br>"

    @encounters.each do |enc|
      enc.location_id = 1
      enc.save
      
      flash[:notice] += "Encounter #{enc.id} updated.<br>"
    end
    redirect_to :controller => :patient, :action => :find
  end

end
