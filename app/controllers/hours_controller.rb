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
    new_hours = check_params[:hours]
    if new_hours.empty?
      alertstring = "HoursController: Hours could not be updated: Invalid string length"
      Rails.logger.warn(alertstring)
      redirect_to hours_path, alert: alertstring
      return # Manditory prevent double redirect
    end
    begin
      # Build into our json format {day: "Monday", opentime: "10A", closetime: "11P"} etc
      new_json  = []
      new_hours.each do |hr|
        new_json << ({ day: hr[:day], opentime: hr[:opentime], closetime: hr[:closetime] })
      end
      openclose.update(new_json)
      redirect_to hours_path, alert: "Hours updated successfully."
    rescue ActiveRecord::RecordInvalid => error
      redirect_to hours_path, alert: "Hours could not be updated: #{error.message}"
    end
  end


  private
  def check_params
    # Grab the raw input array size before filtering
    original_count = params.dig(:hours)&.size || 0

    permitted = params.permit(hours: [ :day, :opentime, :closetime ])

    if permitted[:hours].is_a?(Array)
      # 3. Filter out the invalid elements
      permitted[:hours].reject! do |hour_hash|
        hour_hash[:day].to_s.length > 9 ||
          hour_hash[:opentime].to_s.length > 4 ||
          hour_hash[:closetime].to_s.length > 4
      end

      # Check if the array filtered anything out (or if unpermitted elements were dropped)
      if permitted[:hours].size != original_count
        # Empty the entire array so nothing gets saved
        permitted[:hours] = []
      end
    end
  permitted
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
