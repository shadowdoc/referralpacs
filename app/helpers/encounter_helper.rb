module EncounterHelper
  
  def encounter_links_helper(encounter)
    # Make sure that we get the appropriate links based on the current user
    @links = [] 
    
    # Only users who can modify encounters should see the details and delete links
    if @current_user.privilege.modify_encounter
      @links = [link_to('Details', :action => 'details', :id => encounter.id)]
      @links += [link_to('Delete', 
                         {:action => 'delete', :id => encounter.id}, 
                          :confirm => 'This cannot be undone, are you sure?')]
    end

  end
end
