module EncounterHelper
  
  def encounter_links_helper(encounter)
    # Make sure that we get the appropriate links based on the current user
    links = [] 
    
    # Only users who can modify encounters should see the details and delete links
    if @current_user.privilege.modify_encounter

      if ["radiologist", "admin", "super_radiologist", "assistant"].include?(@current_user.privilege.name) && encounter.status != "final"
        links << link_to('Create Report', {:action => 'report', :id => encounter.id}, :class => "btn btn-default")
      end

      if !["final", "ready_for_printing"].include?(encounter.status)
        links << link_to('Edit Details', {:action => 'details', :id => encounter.id}, :class => "btn btn-default")
      end
      
      # Only show the print link if there is an available report
      if encounter.status == "final" || encounter.status == "ready_for_printing"
        links << link_to('Print Report', {:action => 'pdf_report', :id => encounter.id, :format => :pdf}, :class => "btn btn-default")
      end

      links << link_to('Delete', 
                         {:action => 'delete', :id => encounter.id}, 
                          :confirm => 'This cannot be undone, are you sure?', :class => "btn btn-default")
    end

    return links

  end

  def encounter_summary_header(encounter)
    string = ""
    string += @patient.nil? ? encounter.patient.full_name + " : " : ""
    string += encounter.date.strftime("%d %b %Y") + " : "
    string += encounter.encounter_type.name
    return string.html_safe
  end
  
  #These are the helpers that create the report form.
  
  def radio_tag_helper(value_concept, answer_concept)
    if answer_concept == "none" || answer_concept == "normal"
      test = !@tag_hash.has_key?(value_concept)
    else
      test = @tag_hash[value_concept] == answer_concept
    end
    return_string = "<label class=\"radio small\">" + radio_button_tag(value_concept, answer_concept, test) + answer_concept.humanize + "</label>"
    return_string.html_safe
  end
  
  def fieldset_helper(question, choices)
    return_string = ""    
    choices.each do |choice|
      return_string += radio_tag_helper(question, choice) + "\n"
    end
    return_string.html_safe
  end
  
  def checkbox_helper(question, choices)
    return_string = ""
    
    choices.each do |choice|
      return_string += "<label class=\"checkbox\">" + check_box_tag(question + "+" + choice, true, @tag_hash[question][choice]) + choice.humanize + "</label>" + "\n"
    end
    return_string.html_safe
  end
  
end
