module CycleTimetableHelper
  def mid_cycle
    rand(previous_end_of_cycle_timetable[:apply_reopens]..current_end_of_cycle_timetable[:apply_1_deadline]).midday
  end

  def after_apply_1_deadline
    rand((current_end_of_cycle_timetable[:apply_1_deadline] + 1.day)..current_end_of_cycle_timetable[:stop_applications_to_unavailable_course_options]).midday
  end

  def after_full_course_deadline
    rand((current_end_of_cycle_timetable[:stop_applications_to_unavailable_course_options] + 1.day)..current_end_of_cycle_timetable[:apply_2_deadline]).midday
  end

  def after_apply_2_deadline
    rand((current_end_of_cycle_timetable[:apply_2_deadline] + 1.day)..current_end_of_cycle_timetable[:find_closes]).midday
  end

  def after_find_closes
    rand((current_end_of_cycle_timetable[:find_closes])..current_end_of_cycle_timetable[:find_reopens]).midday
  end

  def after_find_reopens
    rand((current_end_of_cycle_timetable[:find_reopens])..current_end_of_cycle_timetable[:apply_reopens]).midday
  end

  def after_apply_reopens
    rand((current_end_of_cycle_timetable[:find_reopens])..Date.new(EndOfCycleTimetable::CURRENT_YEAR_FOR_SCHEDULE, 12, 31)).midday
  end

private

  def previous_end_of_cycle_timetable
    EndOfCycleTimetable::CYCLE_DATES[EndOfCycleTimetable::CURRENT_YEAR_FOR_SCHEDULE - 1]
  end

  def current_end_of_cycle_timetable
    EndOfCycleTimetable::CYCLE_DATES[EndOfCycleTimetable::CURRENT_YEAR_FOR_SCHEDULE]
  end
end
