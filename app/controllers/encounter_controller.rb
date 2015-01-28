class EncounterController < ApplicationController
  before_filter :authorize_login
  before_filter :security, :except => [:find] # make sure to check permission for all except find and show
  
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
    @encounter = Encounter.new 
    @encounter.patient_id = @patient.id
    @encounter.status = "ordered" # New exams are just "ordered" until they have an image.
    @observation = Observation.new
    @observation.encounter = @encounter
    @observation.patient = @patient
    
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
    @encounter.status = "final"
    @encounter.save

    send_data(@encounter.pdf_report, :filename => "#{@encounter.date.strftime("%d-%m-%y")}-#{@encounter.patient.full_name}.pdf", :type => "application/pdf")

  end
  
  def report
    # Process input from master reporting form.
        
    @encounter = Encounter.find(params[:id])
    @patient = @encounter.patient

    # We use a hash with question_concept, value_concept pairs to
    # transfer data to the form, where it's processed by helpers

    @tag_hash = {"pleural_scarring" => {}}


    if request.get?

      # @impression is the variable that will populate the free-text impression
      # it defaults to normal

      case @encounter.status
        when "ready_for_printing"
          @impression = @encounter.impression
        when "new"
          @impression = "Normal"
        when "opened"
          if @encounter.impression.nil?
            @impression = "Normal"
          else
            @impression = @encounter.impression
          end
      end


      # Let's set the status to "opened" so that this encounter doesn't
      # show up on the "new" list.  This is our attempt at avoiding concurrent
      # reports

      @encounter.status = "opened"
      @encounter.save!

      # Here we load all of the existing observations to fill out the form.

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


    elsif request.post?
      # We have a post request, let's process the record


      if @encounter.observations.count == 0 && params[:impression] == ""
        flash[:notice] = "A valid report must contain checked observations and an impression"
      else
        # First let's clear the previous observations
        @encounter.observations.each {|obs| obs.destroy }

        process_form(params)

        @encounter.impression = params[:impression]
        @encounter.provider = @current_user
        @encounter.status = "ready_for_printing"
        @encounter.save        
      end

      # This is a private method in this controller
      # That creates quality checks for encounters.
      add_quality_check
      
      # If there are no errors, let's send the user back to the worklist
      # Which would be Radiologist To Review or New
      
      if @encounter.errors.count == 0 && flash[:notice].nil?
        if ["radiologist", "admin", "super_radiologist"].include?(@current_user.privilege.name) && Encounter.where(status: "radiologist_to_review").count > 0
          redirect_to :action => "status", :requested_status => "radiologist_to_review"
        else
          redirect_to :action => "status", :requested_status => "new"
        end
      else
        redirect_to(:action => "report", :id => @encounter)
      end

    end

  end

  def reject
    @encounter = Encounter.find(params[:id])

    # Clear out any existing observations
    @encounter.observations.each {|obs| obs.destroy }
    @encounter.impression = ""

    process_form(params)
    @encounter.status = "rejected"
    @encounter.save

    redirect_to :action => :status, :requested_status => "new"
  end

  
  def statistics

    @patients = Patient.all

    if request.get?
      @start_date = "2005-01-01"
      @end_date = Time.now.strftime("%Y-%m-%d")
    else
      @start_date = params[:report][:start_date]
      @end_date = params[:report][:end_date]
    end

    @encounters_during_range = Encounter.where(date: @start_date..@end_date)

    @stat_hash = Encounter.group(:status).count

  end
  
  def status
    
   @encounters = Encounter.order("date DESC").where("status = ?", params[:requested_status]).limit(10)
    
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

  private
    
  def process_form(form_parameters)
    form_parameters.each_pair do |key, value|
      unless value == "none"  || value == "normal"  || value == "no"  || key == "impression"
        unless ["id", "commit", "action", "controller", "utf8", "authenticity_token"].include? key
          unless key.include?("pleural_scarring")
            question_concept = Concept.where(name: key.humanize.upcase).first

            if question_concept.nil?
              raise "concept #{key.humanize.upcase} not found"
            end

            value_concept = Concept.where(name: value.humanize.upcase).first

          else
            question_concept = Concept.where(name: "PLEURAL SCARRING").first
            value_concept = Concept.where(name: key.split("+")[1].humanize.upcase).first
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

  def add_quality_check
      # This is where we randomly add reports to the QC queue
      if rand(50) == 1
        # Each encounter has a 1/50 chance to create a QCs
        QualityCheck.new do |q|
          q.status = "for_review"
          q.encounter = @encounter
          q.provider = @encounter.provider
          q.save
        end
      end
  end

end
