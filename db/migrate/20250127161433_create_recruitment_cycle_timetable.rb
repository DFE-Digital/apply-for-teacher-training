class CreateRecruitmentCycleTimetable < ActiveRecord::Migration[8.0]
  def change
    create_table :recruitment_cycle_timetables do |t|
      t.datetime :find_opens_at
      t.datetime :apply_opens_at
      t.datetime :apply_deadline_at
      t.datetime :reject_by_default_at
      t.datetime :decline_by_default_at
      t.datetime :find_closes_at
      t.daterange :christmas_holiday_range
      t.daterange :easter_holiday_range
      t.integer :recruitment_cycle_year
      t.index [:recruitment_cycle_year], unique: true

      t.timestamps
    end
  end
end
