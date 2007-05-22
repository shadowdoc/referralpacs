class LoginController < ApplicationController

  before_filter :authorize_login, :except => [:login, :logout]
  layout "ref"
  
  # If the requst is of the GET type, return the add_user
  # form.  Otherwise, we have a POST request, attempt to add the
  # new user and return to the user list.
  
  def index
    redirect_to(:action => "login")
  end

  def login
    if request.get?
      session[:user_id] = nil
      @user = User.new
    else
      @user = User.new(params[:user])
      logged_in_user = @user.try_to_login
      if logged_in_user
        session[:user_id] = logged_in_user.id
        redirect_to(:controller => logged_in_user.privilege.name, :action => "find_patients")
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
    @all_clients = Client.find_all
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
    
end
