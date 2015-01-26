module ApplicationHelper

  def errors_for(obj)
    html = ""
    if obj.errors.any?
      html << "<ul>"
        obj.errors.full_messages.each do |msg|
          html << "<li>#{msg}</li>"
        end
      html << "</ul>"
    end
    html.html_safe
  end

  def setup_layout
    # This method is called by the layout view to make sure that the patient 
    # being displayed is correct.
    # It also finds the name of the user whom is logged in, and displays 
    # the link choices accordingly.
    
    set_current_patient_banner
    
    set_current_user_banner_and_command_list
    
  end
  
  def set_current_patient_banner
    
    unless @patient.nil? || @patient.full_name.nil?
      @current_patient_banner = link_to("#{@patient.given_name} #{@patient.middle_name} #{@patient.family_name}", :controller => :encounter, :action => :find, :id => @patient.id) + " | AMPATH ID: " + @patient.mrn_ampath.to_s + " | Age: " + @patient.current_age.to_s + " | Verified: " + @patient.openmrs_verified.to_s
    end
    
  end
  
  def set_current_user_banner_and_command_list
    unless session[:user_id].nil?
      @user = User.find(session[:user_id])
      unless @user.nil?
                
        # Here we put together the command list that will be at the top of every page

        find_patients = link_to('Find Patients', :controller => :patient, :action => :find)
        manage_clients = link_to('Manage Clients', :controller => :login, :action => :list_clients)
        admin = link_to('Admin', :controller => :login, :action => :administration)
        stats = link_to('Statistics', :controller => :encounter, :action => :statistics)
        radiologist_to_review = link_to('For Rad Review', :controller => :encounter, :action => :status, :requested_status => "radiologist_to_review")
        new = link_to('New Exams', :controller => :encounter, :action => :status, :requested_status => "new")
        archived = link_to('Archived', :controller => :encounter, :action => :status, :requested_status => "archived")
        quality = link_to('Quality', :controller => :quality, :action => :list)
        ready_to_print = link_to('Printing', :controller => :encounter, :action => :status, :requested_status => "ready_for_printing")
        rejected = link_to('Rejected', :controller => :encounter, :action => :status, :requested_status => "rejected")
        logoff = link_to('Log Off', {:controller => :login, :action => :login})

        @command_list = []
        
        case @user.privilege.name
          when "admin"
            @command_list = [find_patients,
                             new,
                             radiologist_to_review,
                             ready_to_print,
                             rejected,
                             quality,
                             admin,
                             stats,
                             logoff]
          when "radiologist"
            @command_list = [find_patients,
                             new,
                             radiologist_to_review,
                             ready_to_print,
                             logoff]
          when "super_radiologist"
            @command_list = [find_patients,
                             new,
                             radiologist_to_review,
                             quality,
                             ready_to_print,
                             logoff]
          when "assistant"
            @command_list = [find_patients,
                             new,
                             radiologist_to_review,
                             ready_to_print,
                             logoff]
          when "tech"
            @command_list = [find_patients,
                             new,
                             radiologist_to_review,
                             ready_to_print,
                             manage_clients,
                             logoff]
          when "client"
            @command_list = [find_patients]
            
          else
            @command_list = [find_patients]
        end
        
        

      end
    end
  end
    
  def getBirthDateStart
    Time.now.year - 100
  end

  def getBirthDateEnd
    Time.now.year
  end
  
  # Fill all of the collections for dropdown selections
  def fillCollections
    @all_encounter_types = EncounterType.all
    @all_providers = Provider.all
    @all_clients = Client.all
    @all_locations = Location.all

    @statuses = []
    Struct.new("Status", :id, :name)
    status_array = ["ordered", "new", "opened", "ready_for_printing", "final", "rejected", "archived"]

    status_array.each {|s| @statuses << Struct::Status.new(s, s) }
      
  end
end
