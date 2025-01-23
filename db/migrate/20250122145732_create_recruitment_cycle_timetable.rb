class CreateRecruitmentCycleTimetable < ActiveRecord::Migration[8.0]
  def change
    create_table :recruitment_cycle_timetables do |t|
      t.datetime :find_opens
      t.datetime :apply_opens
      t.datetime :apply_deadline
      t.datetime :reject_by_default
      t.datetime :decline_by_default
      t.datetime :find_closes
      t.daterange :christmas_holiday
      t.daterange :easter_holiday
      t.boolean :real_timetable, default: false
      t.integer :recruitment_cycle_year

      t.timestamps
    end
  end
end
