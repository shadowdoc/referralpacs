class AdminController < ApplicationController
  
  before_filter :authorize_login
  layout "ref"
  
  def index
    redirect_to(:action => "find_patients")
  end

  def merge_patients
    if request.get?
      @patient0 = Patient.new()
      @patient1 = Patient.new()
    else

    end
  end
  
  def set_patient
    mtrh_rad_id = params[:mtrh_rad_id]
    @which_patient = params[:which_patient]
    @patient = Patient.find(:first, :conditions => ['mtrh_rad_id = ?', mtrh_rad_id])
    if @patient.nil?
      flash[:notice] = "Patient could not be set, please enter a valid MTRH Radiology ID"
    else
      render :action => "set_patient", :locals => {:patient => @patient,
                                                   :which_patient => @which_patient }
    end
  end
  
  def add_user
    @current_user = User.find(session[:user_id])
    @all_privileges = Privilege.find(:all)
    if request.get?
      @user = User.new
      # Sets the default privilege level to "Client"
      @user.privilege_id = 2
    else 
      @user = User.new(params[:user])
      if @user.save
        flash[:notice] = "User #{@user.email} created."
        redirect_to(:action => 'list_users')
      end
    end
  end

  # Delete the user with the given ID from the database.
  # The model raises an exception if we attempt to delete
  # the special user.
  def delete_user
    @current_user = User.find(session[:user_id])
    id = params[:id]
    if id == session[:user_id]
      flash[:notice] = "Can't delete self"
    else
      if id && user = User.find(id)
        begin
          user.destroy
          flash[:notice] = "User deleted"
        rescue
          raise error_messages
          flash[:notice] = "Can't delete that user"
        end
      end
    end
    redirect_to(:action => :list_users)
  end

  def list_users
    @all_users = User.find(:all, :conditions => "type IS NULL")
  end
  
  def edit_user
    id = params[:id]
    @user = User.find(id)
    @all_privileges = Privilege.find(:all)
  end
  
  def update_user
    id = params[:id]
    @user = User.find(id)
    @all_privileges = Privilege.find(:all)
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'list_users'
    else
      render :action => 'edit_user'
    end
  
  end
  
  def list_providers
    @all_providers = Provider.find(:all)
  end

  def add_provider
    if request.get?
      @provider = Provider.new
      @all_privileges = Privilege.find(:all)
    else
      @provider = Provider.new(params[:provider])
      if @provider.save
        flash[:notice] = "Provider #{@provider.email} created."
        redirect_to(:action => "list_providers")
      end  
    end
  end
  
  def edit_provider

    if request.get?
      @all_privileges = Privilege.find(:all)
      @provider = Provider.find(params[:id])
    else
      @provider = Provider.find(params[:id])
      if @provider.update_attributes(params[:provider])
        flash[:notice] = "Provider #{@provider.email} was successfully updated"
        redirect_to :action => "list_providers"
      else
        @all_privileges = Privilege.find(:all)
      end
    end
    
  end
    
  def add_image
    @image = Image.create(params[:image])
    flash[:notice] = 'File uploaded'
    redirect_to :action => 'show_encounter', :id => @image.encounter.id
  end
  
  def del_encounter
    @encounter = Encounter.find(params[:id])
    @patient = @encounter.patient
    begin 
      @encounter.destroy
      flash[:notice] = "Encounter deleted."
    rescue
      flash[:notice] = "Could not delete encounter."
    end 
    redirect_to :action => "find_encounters", :id => @patient.id
  end
  
  def statistics
    @patients = Patient.find(:all)
    if request.get?
      @start_date = Time.now.strftime("%Y-%m-%d")
      @end_date = @start_date
      @encounters_during_range = Encounter.find_range
    else
      @start_date = params[:report][:start_date]
      @end_date = params[:report][:end_date]
      @encounters_during_range = Encounter.find_range(params[:report][:start_date], params[:report][:end_date])
    end
    
    @reports_during_range = 0
    for enc in @encounters_during_range
      if enc.observations.length > 0 
        @reports_during_range += 1
      end
    end
  end
  
end