class LoginController < ApplicationController

  before_filter :authorize, :except => "login"
  layout "admin"
  scaffold :user
  
  # If the requst is of the GET type, return the add_user
  # form.  Otherwise, we have a POST request, attempt to add the
  # new user and return to the user list.
  def add_user
    if request.get?
      @user = User.new
    else 
      @user = User.new(params[:user])
      if @user.save
        flash[:notice] = "User #{@user.email} created."
        redirect_to(:action => "list_users")
      end
    end
  end

  # Delete the user with the given ID from the database.
  # The model raises an exception if we attempt to delete
  # the special user.
  def delete_user
    id = params[:id]
    if id && user = User.find(id)
      begin
        user.destroy
        flash[:notice] = "User #{user.name} deleted"
      rescue
        flash[:notice] = "Can't delete that user"
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
        redirect_to(:action => "list_users")
      else
        flash[:notice] = "Invalid user/password combination"
      end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to(:action => "login")
  end
  
end
