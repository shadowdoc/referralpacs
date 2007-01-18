class TechController < ApplicationController

  before_filter :authorize_login
  ENCOUNTERS_PER_PAGE = 10
  layout "ref"
  
#  verify :method => :post, :only => [ :upload_image, :remove_image],
#         :redirect_to => {:action => :find_patients}
  
  def index
    redirect_to :action => 'find_patients'
  end
  
  def find_patients

    if request.post?
      search_hash = params[:search]
      search_criteria = search_hash['search_criteria']

      case search_hash['identifier_type']
        when 'name'
          @patients = Patient.find(:all, :conditions => ["given_name = ? OR family_name = ?", search_criteria, search_criteria], :limit => 10)
        when 'mrn_ampath'
          @patient = Patient.find(:first, :conditions => ['mrn_ampath = ?', search_criteria])
          if @patient
            redirect_to(:action => :find_encounters, :id => @patient.id)
          else
            flash[:notice] = "No such patient: mrn_ampath = #{search_criteria}.  Click New Patient"
          end
        when 'mtrh_rad_id'
          @patient = Patient.find(:first, :conditions => ['mtrh_rad_id = ?', search_criteria])
          if @patient
            redirect_to(:action => :find_encounters, :id => @patient.id)
          else
            flash[:notice] = "No such patient: mtrh_rad_id = #{search_criteria}.  Click New Patient"
          end
      end
      
    end
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
    # Technologists will not be able to edit existing encounters
    @encounter = Encounter.find(params[:id])
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
  end
end
