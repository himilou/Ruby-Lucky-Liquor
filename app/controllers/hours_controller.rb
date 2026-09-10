class HoursController < ApplicationController
  # Note this controller does not allow the creating of new users, only authenticates existing users

  helper_method :current_user, :logged_in?

  def new
    # Renders the login form
  end

  def create
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Logged in sucessfully!"
      puts "#{user.username} logged in"
      redirect_to hours_path
    else
      puts "login failed"
      redirect_to hours_new_path(),  notice: "login failed"
    end
  end

  def changepassword
    if ! logged_in?
      redirect_to hours_new_path(),  notice: "You must be logged in"
    end
    pw = params[:password]
    pwconfirm =  params[:confirmpassword]

    if pw != pwconfirm
      redirect_to hours_new_path(),  notice: "passwords must match."
    end
    current_user ||= User.find(session[:user_id])

    if current_user.update(password: pw)
      session[:user_id] = nil
      redirect_to hours_new_path(),  notice: "password changed"
    else
      redirect_to hours_new_path(),  notice: "Error occured. Password not updated"
    end
  end


  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out!"
    redirect_to hours_new_path(),  notice: "sucessfully logged out"
  end




  def current_user
    # Find the user if a session exists, and memoize it
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    # Returns true if current_user is present, false otherwise
    current_user.present?
  end
end
