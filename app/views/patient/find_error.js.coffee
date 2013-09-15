# This displays the error message
$('#patient-list').html '<%= j @response_string %> <br/><br/> <%= link_to('Create New Patient', :action => :new) if @current_user.privilege.add_patient %>'

# This will reset the form
$('#patient-form')[0].reset()