module TechHelper

  def set_tech_sidebar
    if @patient.nil? || @patient.new_record?
      @side_bar_commands = [
          link_to('Find Patients', :action => :find_patients),
          link_to('New Patient', :action => :new_patient)]
    else
      @side_bar_commands = [
          link_to('Find Patients', :action => :find_patients),
          link_to('New Patietnt', :action => :find_patients),
          link_to("#{@patient.full_name}", :action => :find_encounters, :id => @patient)] 
    end
  end
  
end
