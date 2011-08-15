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
      redirect_to :controller => "patient", :action => "find"
    end 
  end

  public
  
  def details
    @encounter = Encounter.find(params[:id])
    @observation = Observation.new(:encounter_id => @encounter.id)
  end
  
  def edit
  
    # This routine either creates a new encounter if it's called without a parameter, or 
    # Saves changes to an edited encounter when called with an Encounter.id
  
    if params[:id].nil?
      @encounter = Encounter.new(params[:encounter])
      @encounter.status = "ordered"
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
    @encounter.status = "ordered" # New exams are just "ordered" until they have an image.
    @observation = Observation.new(:encounter_id => @encounter.id, :patient_id => @encounter.patient.id)
    
  end

  def new_dcm4chee(dcm_study)
    # This method is called from the script that reads from the dcm4chee database.
    # It recieves a dcm4chee_study object, and then does several actions including
    # finding or creating a new patient.

    # Right now we are only accepting CRs so we will only accept images from that SOP class

    if dcm_study.dcm4chee_series[0].dcm4chee_instances[0].sop_cuid == "1.2.840.10008.5.1.4.1.1.1"

      dcm_patient = dcm_study.dcm4chee_patient
      dcm_mrn = dcm_patient.pat_id

      patient = Patient.find_openmrs(dcm_mrn)

      if patient.nil?
        # We have a new patient, but the OpenMRS server appears to be down or doesn't know the patient.
        patient = Patient.new

        patient.mrn_ampath = dcm_mrn
        patient.family_name, patient.given_name, patient.middle_name = dcm_patient.pat_name.split("^") # Standard HL7 names are used in DICOM
        patient.birthdate = dcm_patient.pat_birthdate
        patient.save!
      end

      enc = Encounter.new
      enc.patient_id = patient.id
      enc.date = dcm_study.study_datetime
      enc.status = "new"
      enc.study_uid = dcm_study.study_iuid
      enc.encounter_type_id = 1 # These are all CXRs
      enc.save!

      # Loop through each series to make sure we get all of the CXRs

      dcm_study.dcm4chee_series.each do |s|
        s.dcm4chee_instances.each do |i|
          image = Image.new
          image.encounter_id = enc.id
          image.instance_uid = i.sop_iuid
          image.save!
        end
      end
    end
  end
  
  def delete
    # Given an encounter id
    # This method will delete an encounter
    # and return a message to its view.
    
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
    @encounter.status = "final"
    @encounter.save

    prawnto :prawn => {
      :page_size => 'A4',
      :left_margin => 50,
      :right_margin => 50,
      :top_margin => 24,
      :bottom_margin => 24},
      :filename => "#{@encounter.date.strftime("%d-%m-%y")}-#{@patient.full_name}.pdf"

    render :layout => false
  end
  
  def report
    # Process input from master reporting form.
        
    @encounter = Encounter.find(params[:id])
    @patient = @encounter.patient

    # We use a hash with question_concept, value_concept pairs to
    # transfer data to the form, where it's processed by helpers

    @tag_hash = {"pleural_scarring" => {}}


    if request.get?

      # Pull an array of the comparison exams, sorted by date.

      array = @patient.encounters.sort! {|x, y| y.date <=> x.date }
      @comparisons = []
      array.each do |comp|
        if !comp.images.empty? && comp.id != @encounter.id
          @comparisons << comp
        end
      end

      # Limit @comparisons to 5
      @comparisons = @comparisons.to(4).from(1) if @comparisons.length > 5

      # Let's set the status to "opened" so that this encounter doesn't
      # show up on the "new" list.  This is our attempt at avoiding concurrent
      # reports

      @encounter.status = "opened"
      @encounter.save!

    elsif request.post?
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
      # Which would be Radiologist To Review or new for a rad and Triage for an assistant
      
      if @encounter.errors.count == 0
        if Encounter.find_all_by_status("radiologist_to_review").empty?
          redirect_to :action => "status", :requested_status => "new"
        else
          redirect_to :action => "status", :requested_status => "radiologist_to_review"
        end
      end

    
      @observations = @encounter.observations

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

  end

  def reject
    @encounter = Encounter.find(params["id"])

    # Clear out any existing observations
    @encounter.observations.each {|obs| obs.destroy }
    @encounter.impression = ""

    process_form(params)
    @encounter.status = "rejected"
    @encounter.save

    redirect_to :action => :status, :requested_status => "new"
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
    
    @new = Encounter.find_all_by_status("new").length    
    @ready_for_printing = Encounter.find_all_by_status("ready_for_printing").length
    @radiologist_to_read = Encounter.find_all_by_status("radiologist_to_read").length
    @final = Encounter.find_all_by_status("final").length
    @archived = Encounter.find_all_by_status("archived").length
    @rejected = Encounter.find_all_by_status("rejected").length
    @ordered = Encounter.find_all_by_status("ordered").length
  end
  
  def status
    
   @encounters = Encounter.find_all_by_status(params[:requested_status], :limit => 10, :order => "date ASC")
    
    if @encounters.length == 0
      render :text => "No encounters with status - #{params[:requested_status].humanize}", :layout => true
    end
    
  end

  def study_fixed
    # This method is called from the Encounter Details page
    # It takes an ID and removes the observations that correspond with the rejection
    # of the encounter and moves it back to the new list

    @encounter = Encounter.find(params[:id])
    @encounter.observations.each {|obs| obs.destroy }
    @encounter.status = "new"
    @encounter.save

    redirect_to :controller => :encounter, :action => :status, :requested_status => "new"
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

    # The tag_hash needs to be populated in order for the rejection categories to work correctly.
    @tag_hash = {"pleural_scarring" => {}}

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
            value_concept = Concept.find_by_name(key.split("+")[1].humanize.upcase)
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
