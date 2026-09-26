class HoursController < ApplicationController
  # Note this controller does not allow the creating of new users, only authenticates existing users

  before_action :require_user, only: [ :main, :update_hours ]




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
