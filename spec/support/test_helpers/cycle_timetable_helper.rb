module CycleTimetableHelper
  def mid_cycle(year = CycleTimetable.current_year)
    CycleTimetable.apply_opens(year) + 1.day
  end

  def after_apply_1_deadline
    CycleTimetable.apply_1_deadline + 1.day
  end

  def after_apply_2_deadline
    CycleTimetable.apply_2_deadline + 1.day
  end

  def after_apply_reopens(year = CycleTimetable.next_year)
    CycleTimetable.apply_reopens(year) + 1.day
  end
end

module RecruitmentCycle
  CYCLES = {
    '2023' => '2022 to 2023',
    '2022' => '2021 to 2022',
    '2021' => '2020 to 2021',
    '2020' => '2019 to 2020',
    '2019' => '2018 to 2019',
  }.freeze
end
