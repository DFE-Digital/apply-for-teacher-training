module RecruitmentCycleTimetableConcern
  def current_timetable
    Current.timetable || RecruitmentCycleTimetable.current_timetable
  end

  def current_cycle_year
    Current.cycle_year || RecruitmentCycleTimetable.current_year
  end
end
