class HoursController < ApplicationController
  # Note this controller does not allow the creating of new users, only authenticates existing users

  before_action :require_user, only: [ :main, :changepassword, :update_hours ]




  def main
    @welcome = "hours main page"
    jsonhours = JsonOpenClose.new
    @current = jsonhours.get
    @form_fields = @current
  end

  def update_hours
     openclose = JsonOpenClose.new
    begin
      new_hours = check_params[:hours]
      # Build into our json format {day: "Monday", opentime: "10A", closetime: "11P"} etc
      new_json  = []
      new_hours.each do |hr|
        new_json << ({ day: hr[:day], opentime: hr[:opentime], closetime: hr[:closetime] })
      end
      openclose.update(new_json)
      redirect_to hours_path, notice: "Hours updated successfully."
    rescue ActiveRecord::RecordInvalid => error
      redirect_to hours_path, alert: "Hours could not be updated: #{error.message}"
    end
  end

  def new
  end

  # authentication methods follow
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
      redirect_to hours_path
    else
      puts "login failed"
      Rails.logger.warn("Login failed for user: #{params[:username]}")
      redirect_to newlogin_path(),  notice: "login failed"
    end
  end

  def changepassword
    if ! logged_in?
      redirect_to newlogin_path(),  notice: "You must be logged in"
    end
    pw = params[:password]
    pwconfirm =  params[:confirmpassword]

    if pw != pwconfirm
      redirect_to newlogin_path(),  notice: "passwords must match."
    end
    juser = JsonUser.new
    current_user ||= juser.find_by_id(session[:user_id])

    if juser.update_pw(current_user.username, params[:password])
      session[:user_id] = nil
      Rails.logger.info("#{current_user.username} changed password at #{Time.now}")
      redirect_to newlogin_path(),  notice: "password changed"
      nil
    else
      Rails.logger.info("#{current_user.username} Error changing password #{Time.now}")
      redirect_to newlogin_path(),  notice: "Error occured. Password not updated"
      nil
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out!"
    redirect_to newlogin_path(),  notice: "sucessfully logged out"
  end

  private
  def check_params
    params.permit(hours: [ :day, :opentime, :closetime ])
  end
end

=begin
  def main
    @welcome = "hours main page"
    @hours = OpenCloseTime.order(:id)
  end

  def update_hours
    OpenCloseTime.transaction do
      hours_params.each do |day, values|
        record = OpenCloseTime.find_by(day: day)
        record ||= OpenCloseTime.new(day: day)
        record.update!(opentime: values[:opentime], closetime: values[:closetime], day: day)
      end
    end

    redirect_to hours_path, notice: "Hours updated successfully."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to hours_path, alert: "Hours could not be updated: #{error.message}"
  end
=end
