class EncounterController < ApplicationController
  layout "ref"
  require "railspdf"
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
  
  def status
    
    @encounters = Encounter.find_all_by_status(params[:requested_status])
    
    if @encounters.length == 0
      render :text => "No encounters with status - #{params[:requested_status].humanize}", :layout => true
    end
    
  end
  
  def report
    # Process input from master form.
    
    @encounter = Encounter.find(params[:id])
    @patient = @encounter.patient
    
    if request.post? 
      # We have a post request, let's process the record
      # First let's clear the previous observations
      
      @encounter.observations.each {|obs| obs.destroy }
      
      params.each_pair do |key, value|
        unless value == "none"  || value == "normal"  || value == "no"  || key == "impression"
          unless ["id", "commit", "action", "controller"].include? key
            unless key.include?("pleural_scarring")
              question_concept = Concept.find_by_name(key.humanize.upcase)
              
              if question_concept.nil?
                raise "concept #{key.humanize.upcase} not found"
              end
              
              value_concept = Concept.find_by_name(value.humanize.upcase)
              
            else
              question_concept = Concept.find_by_name("PLEURAL SCARRING")    
              value_concept = Concept.find_by_name(key.split(" ")[1].humanize.upcase)
            end
            
            if value_concept.nil? 
              raise "value #{value.humanize.upcase} not found"
            end
            
            @encounter.observations << Observation.new(:question_concept_id => question_concept.id,
                                                       :value_concept_id => value_concept.id)
          end
        end 
      end
      
      
      if @encounter.observations.count == 0 && params[:impression] == ""
        flash[:notice] = "A valid report must contain either checked observations, or an impression"
      else
        @encounter.impression = params[:impression]
        @encounter.reported = true
        @encounter.save        
      end
      
      # Let's reload our saved work for display to the browser
      @encounter.reload
    end
    
    # Now we should have observations, let's load them.
    
    @observations = @encounter.observations
    
    # We use a hash with question_concept, value_concept pairs to
    # transfer data to the form, where it's processed by helpers
      
    @tag_hash = {"pleural_scarring" => {}}

    @observations.each do |obs|
      # Since pleural scarring can have multiple results
      # we need to deal with it separately
      if obs.question_concept.html_name == "pleural_scarring"
        @tag_hash["pleural_scarring"].merge!({obs.value_concept.html_name => true})
      else
        @tag_hash.merge!({obs.question_concept.html_name => obs.value_concept.html_name})
      end
        
    end

    # @impression is the variable that will populate the free-text impression
    # it defaults to normal
    if @encounter.reported
      @impression = @encounter.impression
    else
      @impression = "Normal"
    end

  end
  
  def pdf_report
    @encounter = Encounter.find(params[:id])
    @observations = @encounter.observations.sort! {|x, y| y.question_concept.name <=> x.question_concept.name }
    @patient = @encounter.patient
    render :layout => false
  end

end
