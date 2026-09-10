class CreateOpenCloseTimes < ActiveRecord::Migration[8.0]
  def change
    create_table :open_close_times do |t|
      t.string :day, null: false, index: { unique: true }
      t.string :opentime, null: false
      t.string :closetime, null: false
      t.boolean :closeallday
      t.string :message
      t.date :expires

      t.timestamps
    end
    OpenCloseTime.reset_column_information # forces model to recognize new table fields

    inital_hours = [
      { day: "Monday", opentime: "11A", closetime: "10P" },
      { day: "Tuesday", opentime: "11A", closetime: "10P" },
      { day: "Wednesday", opentime: "11A", closetime: "10P" },
      { day: "Thursday", opentime: "11A", closetime: "10P" },
      { day: "Friday", opentime: "11A", closetime: "11P" },
      { day: "Saturday", opentime: "11A", closetime: "11P" },
      { day: "Sunday", opentime: "11A", closetime: "9P" }
    ]

    inital_hours.each do |d|
      OpenCloseTime.create!(d)
    end
  end
end
