class PatientController < ApplicationController
  layout "ref"

  def find
    # If the request is a get, there is nothing to do.
  
    if request.post?
    
      # If a date is supplied, we'll use that as a filter
      if params[:encounter][:date] == ""
        # AMPATH mrn is the best identifier, so let's see if we have one of those first
        if params[:patient][:mrn_ampath] == ""
          if params[:patient][:mtrh_rad_id] == ""
            # If we don't have any MRN, use the names to search
            @patients = Patient.find(:all, 
                          :conditions => ['LOWER(CONCAT(given_name, " ", family_name)) LIKE ?', '%' + params[:patient][:name].downcase + '%'])
          else
            @patients = Patient.find(:all, 
                        :conditions => ['mtrh_rad_id = ?', params[:patient][:mtrh_rad_id]])
          end
        else
          # AMPATH search code goes here
          @patients = Patient.find(:all,
                      :conditions => ['mrn_ampath = ?', params[:patient][:mrn_ampath]])
        end
        
      else
        @encounters = Encounter.find(:all, :conditions => ['date LIKE ?', '%' + params[:encounter][:date] + '%'])
        @patients = []
        @encounters.each { |enc| @patients << enc.patient }       
        @patients.uniq!
        
        # Now we follow the same logic as above, including the date as a factor
        if params[:patient][:mrn_ampath] == ""
          if params[:patient][:mtrh_rad_id] == ""
            # If we don't have any MRN, use the names to search
            unless params[:patient][:name] == ""
              @patients = @patients.find { |aPatient| aPatient.full_name.include? params[:patient][:name] }
            end
          else
            @patients = @patients.find { |aPatient| aPatient.mtrh_rad_id == params[:patient][:mtrh_rad_id] }
          end
        else
          # AMPATH search code goes here
          @patients = @patients.find { |aPatient| aPatient.mrn_ampath == params[:patient][:mrn_ampath]}
        end
        
        
      end
      if @patients.nil? || @patients.empty?
         render :update do |page|
           if Thread.current['user'].privilege.name == "client"
             page.replace_html "patient-list", "No patients found, please search again"
           else
             page.replace_html "patient-list", "No patients found. <br/><br/>" + link_to("New Patient", :action => :new_patient)
           end
           page.visual_effect :highlight, "patient-list"
           page.form.reset 'patient-form'
         end
      else
         render :partial => "ajax_list_patients"
      end
    end
  end
  
  def new
    @all_tribes = Tribe.find(:all, :order => "name ASC")
    if request.get?
      @patient = Patient.new()
    else
      @patient = Patient.new(params[:patient])
      if @patient.save
        flash[:notice] = 'Patient was successfully created.'
        redirect_to :controller => :encounter, :action => "find", :id => @patient.id
      else
        render :action => 'new'
      end
    end
  end
  
  def edit
    @all_tribes = Tribe.find(:all, :order => "name ASC")
    if request.get?
      @patient = Patient.find(params[:id])
    else
      @patient = Patient.find(params[:id])
      if @patient.update_attributes(params[:patient])
          flash[:notice] = "Saved #{@patient.full_name}"
      else
          flash[:notice] = "Error saving patient."
      end
      redirect_to :action => "find"
    end
  end

end
