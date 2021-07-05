module CycleTimetableHelper
  def mid_cycle
    CycleTimetable::CYCLE_DATES.dig(2020, :apply_reopens) + 1.day
  end

  def after_apply_1_deadline
    CycleTimetable::CYCLE_DATES.dig(2020, :apply_1_deadline) + 1.day
  end

  def after_apply_2_deadline
    CycleTimetable::CYCLE_DATES.dig(2020, :apply_2_deadline) + 1.day
  end

  def after_apply_reopens
    CycleTimetable::CYCLE_DATES.dig(2021, :apply_reopens) + 1.day
  end
end
