# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  require "user"

  before_filter :set_current_user
  
#  include SslRequirement
  
  ENCOUNTERS_PER_PAGE = 10
  
  def authorize_login
    unless session[:user_id] 
      flash[:notice] = "Please log in."
      redirect_to(:controller => "login", :action => "login")
    else
      # Make sure each user is accessing the correct controller
      user = User.find(session[:user_id])
      unless user.privilege.name == controller_name
        redirect_to(:controller => user.privilege.name)
      end
    end
    
  end
  
  def set_current_user
    unless session[:user_id].nil?
      Thread.current['user'] = User.find(session[:user_id])
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
  
  def find_patients
  
    if request.post?
      search_hash = params[:search]
      search_criteria = search_hash['search_criteria']
      
      case search_hash['identifier_type']
#        when 'name'
#          @patients = Patient.find(:all, :conditions => ["given_name = ? OR family_name = ?", search_criteria, search_criteria], :limit => 10)
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
        else
          if params[:patient][:name]
            @patient = Patient.find(:first, 
                       :conditions => [ 'LOWER(CONCAT(given_name, " ", family_name)) LIKE ?',
                       '%' + params[:patient][:name].downcase + '%' ])
            redirect_to(:action => :find_encounters, :id => @patient.id)
          end
      end
    end
  end
  
  def auto_complete_for_patient_name
      @patients = Patient.find(:all, 
                  :conditions => [ 'LOWER(CONCAT(given_name, " ", family_name)) LIKE ?',
                  '%' + params[:patient][:name].downcase + '%' ], 
                  :order => 'family_name ASC',
                  :limit => 8)    
    render :partial => 'shared/patients'
  end  
  
  def show_encounter
    @encounter = Encounter.find(params[:id])
  end
  
  def new_patient
    @all_tribes = Tribe.find(:all)
    if request.get?
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
  
  def view_image
    @image = Image.find(params[:id])
    @encounter = @image.encounter
  end
  
  def rotate
    @image = Image.find(params[:id])
    direction = params[:direction]
    @image.rotate(direction)
    redirect_to(:action => "view_image", :id => @image)
  end
  
  def new_report

  end
  
end