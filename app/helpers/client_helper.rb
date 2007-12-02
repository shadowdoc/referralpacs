module ClientHelper

  def setup_client_layout
    
    set_current_user_banner
  
    if @patient.nil? || @patient.new_record?
      @command_list = [link_to('Find Patient', :action => :find)]
    else
      set_current_patient_banner
      @command_list = [
          link_to('Find Patient', :action => :find),
          link_to("#{@patient.full_name}", :action => :find_encounters, :id => @patient)] 
    end
  end
  
end
