module RecruitmentCycle
  def self.current_year
    CycleTimetable.current_year
  end

  def self.next_year
    CycleTimetable.next_year
  end

  def self.previous_year
    current_year - 1
  end

  def self.cycle_name(year = current_year)
    "#{year - 1} to #{year}"
  end
end
