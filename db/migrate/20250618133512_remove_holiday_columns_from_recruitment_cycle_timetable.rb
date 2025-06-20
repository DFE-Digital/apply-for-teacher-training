class RemoveHolidayColumnsFromRecruitmentCycleTimetable < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :recruitment_cycle_timetables, :christmas_holiday_range, type: :daterange
      remove_column :recruitment_cycle_timetables, :easter_holiday_range, type: :daterange
    end
  end
end
