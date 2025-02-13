module RecruitmentCycleTimetables
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.cycle_timetable = RecruitmentCycleTimetable.current_timetable
      Current.next_cycle_timetable = Current.cycle_timetable.relative_next_timetable
      Current.cycle_week = RecruitmentCycleTimetable.current_cycle_week
      Current.cycle_year = Current.cycle_timetable.recruitment_cycle_year
      Current.previous_cycle_year = Current.cycle_year - 1
      Current.next_cycle_year = Current.cycle_year + 1
    end
  end
end
