# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper

  def setup_layout
    # This method is called by the layout view to make sure that the patient being displayed is correct
    # It also finds the name of the user whom is logged in, and displays the link choices accordingly.
    
    set_current_patient_banner
    
    set_current_user_banner_and_command_list
    
  end
  
  def set_current_patient_banner
    
    unless @patient.nil? || @patient.full_name.nil?
      @current_patient_banner = @patient.full_name + " | AMPATH ID: " + @patient.mrn_ampath.to_s  + " | MTRH Rad ID: " + @patient.mtrh_rad_id.to_s
    end
    
  end
  
  def set_current_user_banner_and_command_list
    unless session[:user_id].nil?
      user = User.find(session[:user_id])
      unless user.nil?
        @current_user_banner = "Logged in as: " + user.email.to_s + " | " + link_to("Log Off", :controller => :login, :action => :logout)
        @command_list = [link_to('Statistics', :controller => :encounter, :action => :statistics),
                         link_to('Manage Users', :controller => :login, :action => :list_users),
                         link_to('Manage Providers', :controller => :login, :action => :list_providers),
                         link_to('Manage Clients', :controller => :login, :action => :list_clients),
                         link_to('Find Patients', :controller => :patient, :action => :find),
                         link_to('New Patient', :controller => :patient, :action => :new)]
  
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
  end
  
end
