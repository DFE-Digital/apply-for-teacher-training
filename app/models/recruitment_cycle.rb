module RecruitmentCycle
  def self.cycle_string(year)
    cycle = cycle_strings.fetch(year.to_s)
    current_year.to_s == year.to_s ? "#{cycle} - current" : cycle
  end

  def self.cycle_strings(upto = current_year + 1)
    2020.upto(upto.to_i).index_with do |year|
      "#{year - 1} to #{year}"
    end.stringify_keys
  end

  def self.current_year
    CycleTimetable.current_year
  end

  def self.next_year
    CycleTimetable.next_year
  end

  def self.previous_year
    current_year - 1
  end

  def self.years_visible_to_providers
    [current_year, previous_year]
  end

  def self.years_visible_in_support
    from_year = HostingEnvironment.production? ? current_year : next_year
    from_year.downto(CycleTimetable::CYCLE_DATES.keys.min)
  end

  def self.years_available_to_register
    current_year.downto(CycleTimetable::CYCLE_DATES.keys.min)
  end

  def self.cycle_name(year = current_year)
    "#{year - 1} to #{year}"
  end

  def self.verbose_cycle_name(year = current_year)
    "October #{year - 1} to September #{year}"
  end
end
