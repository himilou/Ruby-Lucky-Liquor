class ChangeController < ApplicationController
  # Note this controller does not allow the creating of new users, only authenticates existing users

  before_action :require_user, only: [ :changepassword ]


  # Authentication methods follow
  def newlogin
    # Renders the login form
  end

  def createlogin
    juser =  JsonUser.new
    user = juser.find_by_name(params[:username])
    puts user
    if user && juser.test_password(params[:password], user.pwhash)
      session[:user_id] = user.id
      flash[:notice] = "Logged in sucessfully!"
      timenow = Time.now
      Rails.logger.info("#{params[:username]} logged in at #{timenow}")
      puts "#{user.username} logged in"
      redirect_to newlogin_path
    else
      puts "login failed"
      Rails.logger.warn("Login failed for user: #{params[:username]}")
      redirect_to newlogin_path,  notice: "login failed"
    end
  end

  def changepassword
    if ! logged_in?
      redirect_to newlogin_path,  notice: "You must be logged in"
      return
    end
    pw = params[:password]
    pwconfirm =  params[:confirmpassword]

    if pw.empty?
      redirect_to newlogin_path,  notice: "blank password not allowed"
      return
    end

    if pw != pwconfirm
      redirect_to newlogin_path,  notice: "passwords must match."
      return
    end
    juser = JsonUser.new
    current_user ||= juser.find_by_id(session[:user_id])

    if juser.update_pw(current_user.username, params[:password])
      session[:user_id] = nil
      Rails.logger.info("#{current_user.username} changed password at #{Time.now}")
      redirect_to newlogin_path,  notice: "password changed"
      nil # manditory or a double request may occur
    else
      Rails.logger.info("#{current_user.username} Error changing password #{Time.now}")
      redirect_to newlogin_path,  notice: "Error occured. Password not updated"
      nil # manditory
    end
  end
  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out!"
    redirect_to newlogin_path,  notice: "sucessfully logged out"
  end
end
