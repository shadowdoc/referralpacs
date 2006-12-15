class LoginController < ApplicationController
  layout "admin"
  
  def add_user
    if request.get?
      @user = User.new
    else 
      @user = User.new(params[:user])
      if @user.save
        redirect_to_encounters( h("User #{@user.email} created"))
      end
    end
  end

  def delete_user
  end

  def list_users
  end

  def login
  end

  def logoff
  end
end
