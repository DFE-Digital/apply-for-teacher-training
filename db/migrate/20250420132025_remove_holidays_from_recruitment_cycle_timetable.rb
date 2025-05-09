class RemoveHolidaysFromRecruitmentCycleTimetable < ActiveRecord::Migration[8.0]
  def change
    safety_assured { remove_column :recruitment_cycle_timetables, :christmas_holiday_range, type: :daterange }
    safety_assured { remove_column :recruitment_cycle_timetables, :easter_holiday_range, type: :daterange }
  end
end
