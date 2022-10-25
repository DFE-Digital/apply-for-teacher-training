module CycleTimetableHelper
  def mid_cycle(year = CycleTimetable.current_year)
    CycleTimetable.apply_opens(year) + 1.day
  end

  def after_apply_1_deadline(year = CycleTimetable.current_year)
    CycleTimetable.apply_1_deadline(year) + 1.day
  end

  def before_apply_1_deadline(year = CycleTimetable.current_year)
    CycleTimetable.apply_1_deadline(year) - 1.day
  end

  def after_apply_2_deadline(year = CycleTimetable.current_year)
    CycleTimetable.apply_2_deadline(year) + 1.day
  end

  def after_apply_reopens(year = CycleTimetable.next_year)
    CycleTimetable.apply_reopens(year) + 1.day
  end
end
