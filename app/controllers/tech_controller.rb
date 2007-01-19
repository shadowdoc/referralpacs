class TechController < ApplicationController

  before_filter :authorize_login
  ENCOUNTERS_PER_PAGE = 10
  layout "ref"
  
#  verify :method => :post, :only => [ :upload_image, :remove_image],
#         :redirect_to => {:action => :find_patients}
  
  def index
    redirect_to :action => 'find_patients'
  end

  def new_patient
    if request.get?
      @all_tribes = Tribe.find(:all)
      @patient = Patient.new()
    else
      @patient = Patient.new(params[:patient])
      if @patient.save
        flash[:notice] = 'Patient was successfully created.'
        redirect_to :action => "find_encounters", :id => @patient.id
      else
        render :action => 'new_patient'
      end
    end
  end

  def new_encounter
    if request.get? && params[:encounter].nil?
      @all_encounter_types = EncounterType.find(:all)
      @all_providers = Provider.find(:all)
  
      @encounter = Encounter.new()  
      @encounter.patient_id = params[:id]
    else
      @encounter = Encounter.new(params[:encounter])
      if @encounter.save
        flash[:notice] = "Encounter saved"
        redirect_to :action => "upload_image", :id => @encounter
      end
    end
  end

  def upload_image
    @all_encounter_types = EncounterType.find(:all)
    @all_providers = Provider.find(:all)
    @encounter = Encounter.find(params[:id])
    @image = Image.new()
    @image.encounter_id = @encounter.id
  end

  def add_image
    @image = Image.create(params[:image])
    flash[:notice] = 'File uploaded'
    redirect_to :action => 'upload_image', :id => @image.encounter.id
  end
  
  def remove_image
    @image = Image.find(params[:id])
    @encounter = @image.encounter
    @image.destroy
    flash[:notice] = 'Image Destroyed'
    redirect_to :action => 'upload_image', :id => @encounter
  end
end
