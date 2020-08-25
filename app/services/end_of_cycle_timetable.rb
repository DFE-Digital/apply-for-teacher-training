class EndOfCycleTimetable
  DATES = {
    apply_1_deadline: Date.new(2020, 8, 24),
    apply_2_deadline: Date.new(2020, 9, 18),
    find_closes: Date.new(2020, 9, 19),
    find_reopens: Date.new(2020, 10, 3),
    next_cycle_opens: Date.new(2020, 10, 13),
  }.freeze

  def self.between_cycles?(phase)
    phase == 'apply_1' ? between_cycles_apply_1? : between_cycles_apply_2?
  end

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

  def self.find_closes
    date(:find_closes)
  end

  def self.find_reopens
    date(:find_reopens)
  end

  def self.find_down?
    Time.zone.now.between?(find_closes.end_of_day, find_reopens.beginning_of_day)
  end

  def self.next_cycle_opens
    date(:next_cycle_opens)
  end

  def self.between_cycles_apply_1?
    Time.zone.now > date(:apply_1_deadline).end_of_day &&
      Time.zone.now < date(:next_cycle_opens).beginning_of_day
  end

  def self.between_cycles_apply_2?
    Time.zone.now > date(:apply_2_deadline).end_of_day &&
      Time.zone.now < date(:next_cycle_opens).beginning_of_day
  end

  def self.date(name)
    if HostingEnvironment.test_environment? || HostingEnvironment.sandbox_mode?
      if FeatureFlag.active?(:simulate_time_between_cycles)
        return simulate_time_between_cycles_dates[name]
      elsif FeatureFlag.active?(:simulate_time_mid_cycle)
        return simulate_time_mid_cycle_dates[name]
      end
    end

    DATES[name]
  end

  def self.current_cycle_year
    Time.zone.now > next_cycle_opens ? next_cycle_year : Time.zone.today.year
  end

  def self.next_cycle_year
    date(:next_cycle_opens).year + 1
  end

  def self.simulate_time_between_cycles_dates
    {
      apply_1_deadline: 5.days.ago.to_date,
      apply_2_deadline: 2.days.ago.to_date,
      find_closes: 1.day.ago.to_date,
      find_reopens: 5.days.from_now.to_date,
      next_cycle_opens: Date.new(2020, 10, 13) > Time.zone.today ? Date.new(2020, 10, 13) : (Time.zone.today + 1),
    }
  end

  def self.simulate_time_mid_cycle_dates
    {
      apply_1_deadline: 20.weeks.from_now.to_date,
      apply_2_deadline: 22.weeks.from_now.to_date,
      find_closes: 22.weeks.from_now.to_date,
      find_reopens: 25.weeks.from_now.to_date,
      next_cycle_opens: 26.weeks.from_now.to_date,
    }
  end
end
