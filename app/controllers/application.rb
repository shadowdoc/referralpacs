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
  
  def find_patients
    # If the request is a get, there is nothing to do.
  
    if request.post?
      if params[:patient][:mrn_ampath] == ""
        if params[:patient][:mtrh_rad_id] == ""
          @patients = Patient.find(:all, 
                        :conditions => ['LOWER(CONCAT(given_name, " ", family_name)) LIKE ?', '%' + params[:patient][:name].downcase + '%'])
        else
          @patients = Patient.find(:all, 
                      :conditions => ['mtrh_rad_id = ?', params[:patient][:mtrh_rad_id]])
        end
      else
        # AMPATH search code goes here
        @patients = Patient.find(:all,
                    :conditions => ['mrn_ampath = ?', params[:patient][:mrn_ampath]])
      end
      
      if @patients.nil? || @patients.empty?
         render :update do |page|
           if Thread.current['user'].privilege.name == "client"
             page.replace_html "patient-list", "No patients found, please search again"
           else
             page.replace_html "patient-list", "No patients found. <br/><br/>" + link_to("New Patient", :action => :new_patient)
           end
           page.visual_effect :highlight, "patient-list"
           page.form.reset 'patient-form'
         end
      else
         render :partial => "shared/ajax_list_patients"
      end
    end
  end
    
#  def find_patients_old
#    if request.post?
#      search_hash = params[:search]
#      search_criteria = search_hash['search_criteria']
#      
#      case search_hash['identifier_type']
#        when 'mrn_ampath'
#          @patient = Patient.find(:first, :conditions => ['mrn_ampath = ? ', search_criteria])
#          if @patient
#            redirect_to(:action => :find_encounters, :id => @patient.id)
#          else
#            flash[:notice] = "No such patient: mrn_ampath = #{search_criteria}.  Click New Patient"
#          end
#        when 'mtrh_rad_id'
#          @patient = Patient.find(:first, :conditions => ['mtrh_rad_id = ?', search_criteria])
#          if @patient
#            redirect_to(:action => :find_encounters, :id => @patient.id)
#          else
#            flash[:notice] = "No such patient: mtrh_rad_id = #{search_criteria}.  Click New Patient"
#          end
#        else
#          unless params[:patient][:name] == ""
#            @patients = Patient.find(:all, 
#                                    :conditions => [ 'LOWER(CONCAT(given_name, " ", family_name)) LIKE ?',
#                                    '%' + params[:patient][:name].downcase + '%' ])
#            case @patients.length
#              when 0
#                flash[:notice] = "No such patient: name = #{params[:patient][:name]}"              
#              when 1
#                redirect_to(:action => :find_encounters, :id => @patients[0].id)            
#              else
#                render(:action => :list_patients)
#            end
#          else
#            flash[:notice] = "Please enter your search parameters"
#          end         
#      end
#    end
#  end
  
  def new_patient
    @all_tribes = Tribe.find(:all, :order => "name ASC")
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
  
  def edit_patient
    @all_tribes = Tribe.find(:all, :order => "name ASC")
    if request.get?
      @patient = Patient.find(params[:id])
    else
      @patient = Patient.find(params[:id])
      if @patient.update_attributes(params[:patient])
          flash[:notice] = "Saved #{@patient.full_name}"
      else
          flash[:notice] = "Error saving patient."
      end
      redirect_to :action => "find_patients"
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
    @encounter = Encounter.find(params[:id])
    @observation = Observation.new(:encounter_id => @encounter.id)
  end
  
  def edit_encounter
    if params[:id].nil?
      @encounter = Encounter.new(params[:encounter])
      @encounter.save
    else
      @encounter = Encounter.find(params[:id])
      @encounter.update_attributes(params[:encounter])
      @encounter.save
    end
    render :partial => 'shared/edit_encounter', :object => @encounter
  end
  
  def new_encounter
    @patient = Patient.find(params[:id])
    @encounter = Encounter.new()  
    @encounter.patient_id = @patient.id
    @observation = Observation.new(:encounter_id => @encounter.id, :patient_id => @encounter.patient.id)
  end

  def add_observation
    @id = params[:encounter_id]
    @encounter = Encounter.find(@id)
    @concept = Concept.find(:first, :conditions => ["name = ?", params[:concept_name]])
    @value_concept = Concept.find(:first, :conditions => ["name = ?", params[:value_concept_name]])
    @observation = Observation.new(:encounter_id => @encounter.id,
                                   :patient_id => @encounter.patient.id,
                                   :concept_id => @concept.id,
                                   :value_concept_id => @value_concept.id)
    @observation.save
    render :partial => "shared/add_observation", :object => @observation
  end
  
  def remove_observation
    @observation = Observation.find(params[:id])
    @observation.destroy
    render :update do |page|
        page.remove "observation-#{params[:id]}"
    end    
  end

  def upload_image    
    @encounter = Encounter.find(params[:id])
    @image = Image.new()
    @image.encounter_id = @encounter.id
  end

  def add_image
    @image = Image.create(params[:image])
    flash[:notice] = 'File uploaded'
    redirect_to(:action => 'show_encounter', :id => @image.encounter.id)
  end
  
  def remove_image
    @image = Image.find(params[:id])
    @encounter = @image.encounter
    @image.destroy
    render :update do |page|
      page.remove "thumbnail-#{params[:id]}"
    end
  end
  
  def view_image
    @image = Image.find(params[:id])
    @encounter = @image.encounter
  end
  
  def edit_image
    @image = Image.find(params[:id])
    @encounter = @image.encounter
  end
  
  def rotate
    @image = Image.find(params[:id])
    direction = params[:direction]
    @image.rotate(direction)
    redirect_to(:action => "edit_image", :id => @image)
  end
  
  def crop
    @image = Image.find(params[:id])
    if params[:x1] 
      @image.crop(params[:x1].to_i, params[:y1].to_i, params[:width].to_i, params[:height].to_i)
    else
      flash[:notice] = "No crop selected"
    end
    redirect_to(:action => "edit_image", :id => @image)    
  end
  
    def list_clients
    @all_clients = Client.find_all
  end

  def add_client
    if request.get?
      @client = Client.new
      @all_privileges = Privilege.find(:all)
    else
      @client = Client.new(params[:client])
      @client.privilege_id = Privilege.find(:first, :conditions => ['name = ?', "client"])
      if @client.save
        flash[:notice] = "Client #{@client.email} created."
        redirect_to(:action => "list_clients")
      else
        @all_privileges = Privilege.find(:all)
      end  
    end
  end
  
  def edit_client
    if request.get?
      @client = Client.find(params[:id])
      @all_privileges = Privilege.find(:all)
    else
      @client = Client.find(params[:id])
      if @client.update_attributes(params[:client])
        flash[:notice] = "Client #{@client.email} saved."
        redirect_to(:action => "list_clients")
      else
        @all_privileges = Privilege.find(:all)
      end
    end
  end
  
  private
  def find_ampath_patients
    # Code to access the AMPATH REST api
    # Thanks Burke!
    query = CGI.escape(params[:patient][:mrn_ampath])
    url = "https://192.168.5.230/amrs/moduleServlet/restModule/api/patient/"
    username = "refpacs"
    password = "mtrh pacs 30"
    @ampath_patients = Array.new
    
    begin
      open(url + query, :http_basic_authentication => [username, password]) do |f|
        doc = REXML::Document.new f.read
        for element in REXML::XPath.match(doc, "//patient")
          pid = REXML::XPath.match(element, "*/identifier").first
          if pid
            @ampath_patients += []     
          end
        end
      end
    rescue OpenURI::HTTPError => err
      puts "error = " + err
    end
  end
end
