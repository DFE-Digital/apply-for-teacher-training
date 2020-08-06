class EndOfCycleTimetable
  DATES = {
    apply_1_deadline: Date.new(2020, 8, 24),
    apply_2_deadline: Date.new(2020, 9, 18),
  }.freeze

  def self.show_apply_1_deadline_banner?
    Time.zone.now < date(:apply_1_deadline)
  end

  def self.show_apply_2_deadline_banner?
    Time.zone.now < date(:apply_2_deadline)
  end

  def self.date(name)
    DATES[name]
  end
end
