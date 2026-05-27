class AddWinterDatesToRecruitmentCycleTimetable < ActiveRecord::Migration[8.1]
  def change
    add_column :recruitment_cycle_timetables, :winter_reject_by_default_at, :datetime
    add_column :recruitment_cycle_timetables, :winter_decline_by_default_at, :datetime
  end
end
