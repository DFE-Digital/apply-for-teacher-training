class RealCycleSchedule
  attr_reader :year

  def initialize(year)
    @year = year
  end

  def cycle_dates
    {
      find_reopens: Date.new(year - 1, 10, 6),
      apply_reopens: Date.new(year - 1, 10, 13),
      apply_1_deadline: Date.new(year - 1, 8, 24),
      stop_applications_to_unavailable_course_options: Date.new(year - 1, 9, 7),
      apply_2_deadline: Date.new(year - 1, 9, 18),
      find_closes: Date.new(year - 1, 10, 3),
    }.freeze
  end
end
