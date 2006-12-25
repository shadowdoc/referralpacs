class PatientController < ApplicationController

  before_filter :authorize
  layout "admin"

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list_short }

  def list
    @patient_pages, @patients = paginate :patients, :per_page => 10
  end

  def list_short
    @patient_pages, @patients = paginate :patients, :per_page => 10
  end

  def show
    @patient = Patient.find(params[:id])
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(params[:patient])
    if @patient.save
      #flash[:notice] = 'Patient was successfully created.'
      redirect_to :action => 'list_short'
    else
      render :action => 'new'
    end
  end

  def edit
    @patient = Patient.find(params[:id])
  end

  def update
    @patient = Patient.find(params[:id])
    if @patient.update_attributes(params[:patient])
      flash[:notice] = 'Patient was successfully updated.'
      redirect_to :action => 'show', :id => @patient
    else
      render :action => 'edit'
    end
  end

  def destroy
    Patient.find(params[:id]).destroy
    redirect_to :action => 'list_short'
  end
  
  def encounters
    @patients = Patient.find(params[:id])
    @encounters = Encounter.find(:all, :conditions => ["patient_id = ?", params[:id]])
  end
end
