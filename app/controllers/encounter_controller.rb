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
  
  def add_observation
    
    #TODO This code could be removed now that we're using the report form
    #rather than adding single observations.
    
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

  def details
    @encounter = Encounter.find(params[:id])
    @observation = Observation.new(:encounter_id => @encounter.id)
  end
  
  def edit
  
    # This routine either creates a new encounter if it's called without a parameter, or 
    # Saves changes to an edited encounter when called with an Encounter.id
  
    if params[:id].nil?
      @encounter = Encounter.new(params[:encounter])
      @encounter.status = "new"
      @encounter.save
    else
      @encounter = Encounter.find(params[:id])
      @encounter.update_attributes(params[:encounter])
      @encounter.save
    end
    
    render :partial => 'edit_encounter', :object => @encounter
    
  end

  def find
    # This controller will return a list of encounters, given a patient ID.
 
    @patient = Patient.find(params[:id])
    @encounters = @patient.encounters.sort! {|x, y| y.date <=> x.date }
    @current_user = User.find(session[:user_id])

    if @encounters.empty?
      flash[:notice] = "No encounters for #{@patient.full_name}"
    end
  
  end
  
  def new

    # Given a patient.id from the params, this creates a new encounter object and returns
    # it to the view for manipulation.
  
    @patient = Patient.find(params[:id])
    @encounter = Encounter.new()  
    @encounter.patient_id = @patient.id
    @encounter.status = "new"
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
 
    redirect_to :back

  end
  
  def openimages
    # This action is only called via javascript openimages(encounter_id) in 
    # Application.js
    @encounter = Encounter.find(params[:id])
    render :layout => "images"
  end

  def pdf_report
    @encounter = Encounter.find(params[:id])
    @observations = @encounter.observations.sort! {|x, y| y.question_concept.name <=> x.question_concept.name }
    @patient = @encounter.patient
    @rails_pdf_name = "#{@encounter.date.strftime("%d-%m-%y")}-#{@patient.full_name}.pdf"
    @encounter.status = "final"
    @encounter.save
    render :layout => false
  end
  
  def report
    # Process input from master reporting form.
        
    @encounter = Encounter.find(params[:id])
    @patient = @encounter.patient
    array = @patient.encounters.sort! {|x, y| y.date <=> x.date }
    @comparisons = []
    
    array.each do |comp|
      if !comp.images.empty?
        @comparisons << comp
      end
    end
    # Limit @comparisions to 5
    @comparisons = @comparisons.to(4).from(1)
    
    if request.post? 
      # We have a post request, let's process the record
      # First let's clear the previous observations
      
      @encounter.observations.each {|obs| obs.destroy }

      process_form(params)

      if @encounter.observations.count == 0 && params[:impression] == ""
        flash[:notice] = "A valid report must contain either checked observations, or an impression"
      else
        @encounter.impression = params[:impression]
        @encounter.provider = @current_user
        @encounter.status = "ready_for_printing"
        @encounter.save        
      end
      
      # If there are no errors, let's send the user back to the worklist
      # Which would be Radiologist To Review for a rad and Triage for an assistant
      
      if @encounter.errors.count == 0
        if Encounter.find_all_by_status("radiologist_to_review").empty?
          redirect_to :action => "status", :requested_status => "new"
        else
          redirect_to :action => "status", :requested_status => "radiologist_to_review"
        end
      end
    end
    
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
    if @encounter.status != "new"
      @impression = @encounter.impression
    else
      @impression = "Normal"
    end

  end

  def reject
    @encounter = Encounter.find(params["id"])

    # Clear out any existing observations
    @encounter.observations.each {|obs| obs.destroy }
    @encounter.impression = ""

    process_form(params)
    @encounter.status = "rejected"
    @encounter.save

    redirect_to :action => :status, :requested_status => "rejected"
  end

  
  def statistics

    @patients = Patient.find(:all)

    if request.get?
      @start_date = "2005-01-01"
      @end_date = Time.now.strftime("%Y-%m-%d")
      @encounters_during_range = Encounter.find_range(@start_date, @end_date)
    else
      @start_date = params[:report][:start_date]
      @end_date = params[:report][:end_date]
      @encounters_during_range = Encounter.find_range(params[:report][:start_date], params[:report][:end_date])
    end
    
    @new = 0
    
    Encounter.find_all_by_status("new").each do |enc|
      if !enc.images.empty?
        @new += 1
      end
    end
    
    @ready_for_printing = Encounter.find_all_by_status("ready_for_printing").length
    @radiologist_to_read = Encounter.find_all_by_status("radiologist_to_read").length
    @final = Encounter.find_all_by_status("final").length
    @archived = Encounter.find_all_by_status("archived").length
    @rejected = Encounter.find_all_by_status("rejected").length

  end
  
  def status
    
    if params[:requested_status] == "new"
      @encounters = Encounter.find_all_by_status("new")
      encounter_temp = []
      @encounters.each {|e| encounter_temp << e if e.images.count != 0 }
      @encounters = encounter_temp.to(19)
    else
      @encounters = Encounter.find_all_by_status(params[:requested_status], :limit => 20, :order => "date ASC")
    end
    
    if @encounters.length == 0
      render :text => "No encounters with status - #{params[:requested_status].humanize}", :layout => true
    end
    
  end
  
  def triage
    # If we have a get, just return the encounter for the view.
    @encounter = Encounter.find(params[:id])
    
    if request.post?
      if params[:commit] == "Normal"
        @encounter.impression = "Normal"
        @encounter.status = "ready_for_printing"
        @encounter.provider = @current_user
        @encounter.save
      else
        @encounter.status = "radiologist_to_review"
        @encounter.save
      end
      
      redirect_to :action => "status", :requested_status => "new"
    end
    
  end

  private
    
  def process_form(form_parameters)
    form_parameters.each_pair do |key, value|
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
  end

end
