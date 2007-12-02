module TechHelper

  def setup_tech_layout
    
    set_current_user_banner
  
    if @patient.nil? || @patient.new_record?
      @command_list = [
          link_to('Find Patients', :action => :find),
          link_to('Manage Clients', :action => :list_clients)]
    else
      set_current_patient_banner
      @command_list = [
          link_to('Find Patients', :action => :find),
          link_to("#{@patient.full_name}", :action => :find_encounters, :id => @patient)] 
    end
  end
  
end
