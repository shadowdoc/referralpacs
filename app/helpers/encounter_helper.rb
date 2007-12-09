module EncounterHelper
  
  def encounter_links_helper(encounter)
    # Make sure that we get the appropriate links based on the current user

    # Everyone can see the encounter details
    @links = [link_to('Details', :action => 'details', :id => encounter.id)]
    
    # Only users who can modify encounters should see the delete link
    if @current_user.privilege.modify_encounter
      @links += [link_to('Delete', 
                         {:action => 'delete', :id => encounter.id}, 
                          :confirm => 'This cannot be undone, are you sure?')]
    end

  end
end
