class EndOfCycleTimetable
  DATES = {
    apply_1_deadline: Date.new(2020, 8, 24),
    apply_2_deadline: Date.new(2020, 9, 18),
    find_closes: Date.new(2020, 9, 19),
    find_reopens: Date.new(2020, 10, 3),
  }.freeze

  def self.show_apply_1_deadline_banner?
    Time.zone.now < date(:apply_1_deadline)
  end

  def self.show_apply_2_deadline_banner?
    Time.zone.now < date(:apply_2_deadline)
  end

  def self.find_down?
    Time.zone.today.between?(find_closes, find_reopens)
  end

  def self.find_closes
    date(:find_closes)
  end

  def self.find_reopens
    date(:find_reopens)
  end

  def self.date(name)
    DATES[name]
  end
end
