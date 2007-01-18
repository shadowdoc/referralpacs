module TechHelper

  def set_tech_sidebar
    @side_bar_commands = [
      link_to('Find Patients', :action => :find_patients),
      link_to('New Patient', :action => :new_patient)]
  end
  
end
