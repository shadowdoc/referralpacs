class EncounterController < ApplicationController

  before_filter :authorize_login
  layout "admin"
  require "user"
  
  def index 
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    if params[:id]
      @patient = Patient.find(params[:id])
      @encounter_pages, @encounters = paginate :encounters, :conditions => ["patient_id = ?", params[:id]], :per_page => 10
    else
      @encounter_pages, @encounters = paginate :encounters, :per_page => 10      
    end
  end

  def show
    @all_encounter_types = EncounterType.find_all
    @encounter = Encounter.find(params[:id])
  end

  # Creates a new encounter given a patient id.
  def new
    @all_encounter_types = EncounterType.find(:all)
    @all_providers = Provider.find(:all)
    @encounter = Encounter.new()
    @encounter.patient_id = params[:id]
  end

  def create
    @encounter = Encounter.new(params[:encounter])
    if @encounter.save
      flash[:notice] = 'Encounter was successfully created.'
      redirect_to :controller => 'patient', :action => 'encounters', :id => @encounter.patient.id
    else
      render :action => 'new'
    end
  end

  def edit
    @all_providers = Provider.find(:all)
    @all_encounter_types = EncounterType.find_all
    @encounter = Encounter.find(params[:id])
  end

  def update
    @encounter = Encounter.find(params[:id])
    if @encounter.update_attributes(params[:encounter])
      flash[:notice] = 'Encounter was successfully updated.'
      redirect_to :action => 'show', :id => @encounter
    else
      render :action => 'edit'
    end
  end

  def destroy
    Encounter.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
end
