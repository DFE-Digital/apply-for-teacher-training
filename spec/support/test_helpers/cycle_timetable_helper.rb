module CycleTimetableHelper
  def mid_cycle
    previous_end_of_cycle_timetable[:apply_reopens] + 1.day
  end

  def after_apply_1_deadline
    current_end_of_cycle_timetable[:apply_1_deadline] + 1.day
  end

  def after_full_course_deadline
    current_end_of_cycle_timetable[:stop_applications_to_unavailable_course_options] + 1.day
  end

  def after_apply_2_deadline
    current_end_of_cycle_timetable[:apply_2_deadline] + 1.day
  end

  def after_find_closes
    current_end_of_cycle_timetable[:find_closes] + 1.day
  end

  def after_find_reopens
    current_end_of_cycle_timetable[:find_reopens] + 1.day
  end

  def after_apply_reopens
    current_end_of_cycle_timetable[:apply_reopens] + 1.day
  end

private

  def previous_end_of_cycle_timetable
    CycleTimetable::CYCLE_DATES[CycleTimetable::CURRENT_YEAR_FOR_SCHEDULE - 1]
  end

  def current_end_of_cycle_timetable
    CycleTimetable::CYCLE_DATES[CycleTimetable::CURRENT_YEAR_FOR_SCHEDULE]
  end
end
