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

module RecruitmentCycle
  CYCLES = {
    '2022' => '2021 to 2022',
    '2021' => '2020 to 2021',
    '2020' => '2019 to 2020',
    '2019' => '2018 to 2019',
  }.freeze
end
