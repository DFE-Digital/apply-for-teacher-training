module RecruitmentCycle
  def self.cycle_string(year)
    cycle = cycle_strings.fetch(year.to_s)
    current_year.to_s == year.to_s ? "#{cycle} - current" : cycle
  end

  def self.cycle_strings(upto = current_year)
    upto.to_i.downto(2020).index_with do |year|
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
    from_year.downto(CYCLE_DATES.keys.min)
  end

  def self.years_available_to_register
    current_year.downto(CYCLE_DATES.keys.min)
  end

  def self.cycle_name(year = current_year)
    "#{year - 1} to #{year}"
  end

  def self.verbose_cycle_name(year = current_year)
    "October #{year - 1} to September #{year}"
  end

  def self.next_courses_starting_range
    # if it's cycle year 2025 before apply opens (after find opens, eg 2 October 2024)
    # 2025 - 26 (current_year - next year )
    # if it's cycle year 2024 after apply closes (before find closes, eg 29 Sept 2024)
    # 2025 - 26 (next_year - next_year + 1)

    if CycleTimetable.before_apply_opens?
      cycle_name(next_year)
    else
      cycle_name(next_year + 1)
    end
  end

  def self.next_apply_opening_date
    # if it's cycle year 2025 before apply opens (after find opens)
    # October 2024, (apply opens in the current recruitment year, ie apply_opens)
    # if it's cycle year 2024 after apply closes (before find closes)
    # October 2024, (apply opens in the next recruitment year, ie apply reopens)

    if CycleTimetable.before_apply_opens?
      CycleTimetable.apply_opens
    else
      CycleTimetable.apply_reopens
    end
  end
end
