# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def link_list_users
    link_to("List Users", :controller => "login", :action => "list_users")
  end
  
  def link_add_provider
    link_to("Add Provider", :action=> :add_provider)
  end
  
  def link_add_user
    link_to("Add User", :action => "add_user")  
  end
  
  def set_current_patient_banner
    unless @patient.nil?
      @current_patient_banner = @patient.full_name + " | AMPATH ID: " + @patient.mrn_ampath.to_s  + " | MTRH Rad ID: " + @patient.mtrh_rad_id.to_s
    end
  end
    
end
