module RecruitmentCycle
  def self.current_year
    if Time.zone.today < EndOfCycleTimetable.apply_reopens
      2020
    else
      2021
    end
  end

  def self.previous_year
    current_year - 1
  end

  def self.next_year
    current_year + 1
  end

  def self.visible_years
    [current_year, previous_year]
  end
end
