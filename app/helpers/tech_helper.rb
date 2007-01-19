module TechHelper

  def setup_tech_layout
    
    set_current_user_banner
  
    if @patient.nil? || @patient.new_record?
      @command_list = [
          link_to('Find Patients', :action => :find_patients),
          link_to('New Patient', :action => :new_patient)]
    else
      set_current_patient_banner
      @command_list = [
          link_to('Find Patients', :action => :find_patients),
          link_to('New Patient', :action => :find_patients),
          link_to("#{@patient.full_name}", :action => :find_encounters, :id => @patient)] 
    end
  end
  
end
