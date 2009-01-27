# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper

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
      @current_patient_banner = link_to(@patient.full_name, :controller => :encounter, :action => :find, :id => @patient.id) + " | AMPATH ID: " + @patient.mrn_ampath.to_s  + " | MTRH Rad ID: " + @patient.mtrh_rad_id.to_s + " | Current Age: " + @patient.current_age.to_s
    end
    
  end
  
  def set_current_user_banner_and_command_list
    unless session[:user_id].nil?
      user = User.find(session[:user_id])
      unless user.nil?
        
        # First we set up the string that displays the current user.
        
        @current_user_banner = "Logged in as: " + user.email.to_s + " | " + link_to("Log Off", :controller => :login, :action => :logout)
        
        # Here we put together the command list that will be at the top of every page

        find_patients = link_to('Find Patients', :controller => :patient, :action => :find)
        #manage_users = link_to('Manage Users', :controller => :login, :action => :list_users)
        #manage_providers = link_to('Manage Providers', :controller => :login, :action => :list_providers)
        manage_clients = link_to('Manage Clients', :controller => :login, :action => :list_clients)
        admin = link_to('Admin', :controller => :login, :action => :administration)
        stats = link_to('Statistics', :controller => :encounter, :action => :statistics)
        dictionary = link_to('Dictionary', :controller => :dictionary, :action => :list_concepts)
        radiologist_to_review = link_to('For Radiologist Review', :controller => :encounter, :action => :status, :requested_status => "radiologist_to_review")
        new = link_to('New Exams', :controller => :encounter, :action => :status, :requested_status => "new")
        ready_to_print = link_to('Ready for Printing', :controller => :encounter, :action => :status, :requested_status => "ready_for_printing")
        @command_list = []
        
        case user.privilege.name
          when "admin"
            @command_list = [find_patients,
                             dictionary,
                             new,
                             radiologist_to_review,
                             ready_to_print,
                             admin,
                             stats]
          when "radiologist"
            @command_list = [find_patients,
                             new,
                             radiologist_to_review]
          when "assistant"
            @command_list = [find_patients,
                             new,
                             radiologist_to_review,
                             ready_to_print]
          when "tech"
            @command_list = [find_patients,
                             new,
                             radiologist_to_review,
                             ready_to_print,
                             manage_clients]
          when "client"
            @command_list = [find_patients]
            
          else
            @command_list = [find_patients]
        end
        
        

      end
    end
  end
    
  def getBirthDateStart()
    Time.now.year - 100
  end

  def getBirthDateEnd()
    Time.now.year
  end
  
  # Fill all of the collections for dropdown selections
  def fillCollections
    @all_encounter_types = EncounterType.find(:all)
    @all_providers = Provider.find(:all)
    @all_clients = Client.find(:all)
    @all_locations = Location.find(:all)
  end
  
  def javascript(url)
    content_for :javascript do
      javascript_include_tag url
    end
  end
  
end
