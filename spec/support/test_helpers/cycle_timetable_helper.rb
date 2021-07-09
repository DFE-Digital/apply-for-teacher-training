module CycleTimetableHelper
  def mid_cycle
    CycleTimetable.apply_opens(2020) + 1.day
  end

  def after_apply_1_deadline
    CycleTimetable.apply_1_deadline(2020) + 1.day
  end

  def after_apply_2_deadline
    CycleTimetable.apply_2_deadline(2020) + 1.day
  end

  def after_apply_reopens
    CycleTimetable.apply_reopens(2021) + 1.day
  end
end
