module PatientHelper

  def patient_link_helper(patient)
    # Make sure that we get the appropriate links based on the current user

    # Everyone can see the list of encounters for a given patient
    @links = [link_to('Encounters', :controller => :encounter, :action => 'find', :id => patient.id)]
    
    # Only users who can modify patients should see the delete and edit links
    if @current_user.privilege.remove_patient
      @links += [link_to('Edit', 
                         {:action => 'edit', :id => patient.id})]
      @links += [link_to('Delete', 
                         {:action => 'delete', :id => patient.id}, 
                          :confirm => 'This cannot be undone, are you sure?')]
    end

  end
end