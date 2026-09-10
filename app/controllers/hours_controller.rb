class HoursController < ApplicationController
  # Note this controller does not allow the creating of new users, only authenticates existing users

  before_action :require_user, only: [ :main, :changepassword, :update_hours ]


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

  def new
  end

  # authentication methods follow
  def newlogin
    # Renders the login form
  end

  def createlogin
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
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
    current_user ||= User.find(session[:user_id])

    if current_user.update(password: pw)
      session[:user_id] = nil
      Rails.logger.info("#{current_user.username} changed password at #{timenow}")
      redirect_to newlogin_path(),  notice: "password changed"
    else
      Rails.logger.info("#{current_user.username} Error changing password #{timenow}")
      redirect_to newlogin_path(),  notice: "Error occured. Password not updated"
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out!"
    redirect_to newlogin_path(),  notice: "sucessfully logged out"
  end

  private

  def hours_params
    params.require(:hours).permit(
      "Monday" => [ :opentime, :closetime ],
      "Tuesday" => [ :opentime, :closetime ],
      "Wednesday" => [ :opentime, :closetime ],
      "Thursday" => [ :opentime, :closetime ],
      "Friday" => [ :opentime, :closetime ],
      "Saturday" => [ :opentime, :closetime ],
      "Sunday" => [ :opentime, :closetime ]
    )
  end
end
