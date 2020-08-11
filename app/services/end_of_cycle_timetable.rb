class EndOfCycleTimetable
  DATES = {
    apply_1_deadline: Date.new(2020, 8, 24),
    apply_2_deadline: Date.new(2020, 9, 18),
    next_cycles_courses_open: Date.new(2020, 10, 13),
  }.freeze

  def self.show_apply_1_deadline_banner?
    Time.zone.now < date(:apply_1_deadline).end_of_day
  end

  def self.show_apply_2_deadline_banner?
    Time.zone.now < date(:apply_2_deadline).end_of_day
  end

  def self.apply_1_deadline
    date(:apply_1_deadline)
  end

  def self.apply_2_deadline
    date(:apply_2_deadline)
  end

  def self.next_cycles_courses_open
    date(:next_cycles_courses_open)
  end

  def self.show_apply_1_reopen_banner?
    Time.zone.now > date(:apply_1_deadline).end_of_day
  end

  def self.show_apply_2_reopen_banner?
    Time.zone.now > date(:apply_2_deadline).end_of_day
  end

  def self.date(name)
    DATES[name]
  end
end
