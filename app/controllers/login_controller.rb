class LoginController < ApplicationController

  before_filter :authorize_login, :except => [:login, :logout] # Make sure an authorized user is logged in.
  before_filter :security, :except => [:login, :logout] # Make sure current user can edit user data
  layout "ref"

  protected
  def security
    # First we make sure the current user can update user
    # records

    @current_user = User.find(session[:user_id])

    unless @current_user.privilege.update_user
      flash[:notice] = "Not enough privilege to manage users"
      redirect_to(:controller => "patient", :action => "find")
    end

  end

  public

  def login
    # The login function verifies credentials and sets the toolbar for the session.
    
    if request.get?

      session[:user_id] = nil
      @user = User.new
      
    else
      @user = User.new(params[:user])
      logged_in_user = @user.try_to_login
      if logged_in_user
        
        # If the user credentials are correct, set the session[:user_id] = the user logging in.
        
        session[:user_id] = logged_in_user.id
        
        redirect_to(:controller => :patient, :action => "find")
        
      else
        flash[:notice] = "Invalid user/password combination"
      end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to(:action => "login")
  end
  
  def list_clients
    @all_clients = Client.find(:all)
  end

  def add_client
    if request.get?
      @client = Client.new
      @all_privileges = Privilege.find(:all)
    else
      @client = Client.new(params[:client])
      @client.privilege_id = 2 
      if @client.save
        flash[:notice] = "Client #{@client.email} created."
        redirect_to(:action => "list_clients")
      else
        @all_privileges = Privilege.find(:all)
      end  
    end
  end
  
  def edit_client
    if request.get?
      @client = Client.find(params[:id])
      @all_privileges = Privilege.find(:all)
    else
      @client = Client.find(params[:id])
      if @client.update_attributes(params[:client])
        flash[:notice] = "Client #{@client.email} saved."
        redirect_to(:action => "list_clients")
      else
        @all_privileges = Privilege.find(:all)
      end
    end
  end
  
  def list_users
    @users = User.find(:all)
  end
  
  def add_user
    
    # If the request is of the GET type, return the add_user
    # form.  Otherwise, we have a POST request, attempt to add the
    # new user and return to the user list.

    @all_privileges = Privilege.find(:all)
    if request.get?
      @user = User.new
      # Sets the default privilege level to "Client"
      @user.privilege_id = 2
    elsif params[:new][:password1] != params[:user][:password]
      @user = User.new(params[:user])
      flash[:notice] = "Passwords must match"
      redirect_to(:action => "add_user")
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
    id = params[:id]
    
    if id == session[:user_id]
      return flash[:notice] = "Can't delete self"
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
    
  def edit_user
        
    # Now we see if the request is a get and if so, send back a form
    # populated with the user data to be modified.
    @all_privileges = Privilege.find(:all)

    if request.get?
      id = params[:id]
      @user = User.find(id)
    else
      @user = User.find(params[:id])
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        return(redirect_to :action => "list_users")
      end
      
    end  
  end

  def set_password
    # Grab the user that we want to modify
    @user = User.find(params[:id])

    if request.get?
      # We don't do anything here, just display the view
      # We already pulled the user in question so that the
      # ID can be re-posted.

    elsif request.post?
      #Now we check to make sure that the entered passwords match.
      if params[:new][:password0] == params[:new][:password1]

        @user.password = params['new'][:password0]
        @user.save
        flash[:notice] = 'Password updated'
        redirect_to(:controller => :login, :action => :list_users)

        else
          flash[:notice] = 'Requested passwords must match'
      end

    end

  end

  
  def list_providers
    @all_providers = Provider.find(:all)
  end

  def add_provider
    
    @current_user = User.find(session[:user_id])

    unless @current_user.privilege.add_user
      flash[:notice] = "Not enough privilege to add providers"
      return(redirect_to(:controller => "patient", :action => "find"))
    end
    
    if request.get?
      @provider = Provider.new
      @all_privileges = Privilege.find(:all)
    else
      @provider = Provider.new(params[:provider])
      if @provider.save
        flash[:notice] = "Provider #{@provider.email} created."
        redirect_to(:controller => "login", :action => "list_providers")
      end
      
    end
  end
  
  def edit_provider

    @current_user = User.find(session[:user_id])

    unless @current_user.privilege.update_user
      flash[:notice] = "Not enough privilege to edit providers"
      return(redirect_to(:controller => "patient", :action => "find"))
    end

    
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
  
  def administration
    # stub action to show a list of links for management purposes.
  end
    
end
