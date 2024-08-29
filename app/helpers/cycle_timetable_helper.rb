module CycleTimetableHelper
module_function

  def after_find_opens(year = CycleTimetable.current_year)
    CycleTimetable.find_opens(year) + 1.day
  end

  def after_find_reopens(year = CycleTimetable.current_year)
    CycleTimetable.find_reopens(year) + 1.day
  end

  def mid_cycle(year = CycleTimetable.current_year)
    CycleTimetable.apply_opens(year) + 1.day
  end

  def after_apply_deadline(year = CycleTimetable.current_year)
    CycleTimetable.apply_deadline(year) + 1.day
  end

  def cancel_application_deadline(year = CycleTimetable.current_year)
    CycleTimetable.apply_deadline(year)
  end

  def before_apply_deadline(year = CycleTimetable.current_year)
    CycleTimetable.apply_deadline(year) - 1.day
  end

  def after_apply_reopens(year = CycleTimetable.next_year)
    CycleTimetable.apply_reopens(year) + 1.day
  end

  def after_reject_by_default(year = CycleTimetable.current_year)
    CycleTimetable.reject_by_default(year) + 1.day
  end

  def reject_by_default_run_date(year = CycleTimetable.current_year)
    CycleTimetable.reject_by_default(year) + 1.second
  end

  def decline_by_default_run_date(year = CycleTimetable.current_year)
    CycleTimetable.decline_by_default_date(year) + 1.second
  end

  def reject_by_default_reminder_run_date(year = CycleTimetable.current_year)
    CycleTimetable.reject_by_default(year) - 2.weeks
  end

  def application_deadline_has_passed_email_date(year = CycleTimetable.current_year)
    CycleTimetable.apply_deadline(year) + 1.day
  end
end
