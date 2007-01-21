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
    
end
