class AdminController < ApplicationController
  
  before_filter :authorize_login
  layout "ref"
  
  def edit_patient
    @all_tribes = Tribe.find(:all)
    if request.get?
      @patient = Patient.find(params[:id])
    else
      @patient = Patient.find(params[:id])
      if @patient.update_attributes(params[:patient])
          flash[:notice] = "Saved #{@patient.full_name}"
      else
          flash[:notice] = "Error saving patient."
      end
    end
  end

  def merge_patients
  end
  
  def add_user
    @current_user = User.find(session[:user_id])
    @all_privileges = Privilege.find(:all)
    if request.get?
      @user = User.new
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
          flash[:notice] = "User #{user.name} deleted"
        rescue
          flash[:notice] = "Can't delete that user"
        end
      end
    end
    redirect_to(:action => :list_users)
  end

  def list_users
    @all_users = User.find(:all)
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
  
  def list_clients
    @all_clients = Client.find_all
  end

  def add_client

    if request.get?
      @client = Client.new
      @all_privileges = Privilege.find(:all)
    else
      @client = Client.new(params[:client])
      if @client.save
        flash[:notice] = "Client #{@client.email} created."
        redirect_to(:action => "list_clients")
      end  
    end
  end
end