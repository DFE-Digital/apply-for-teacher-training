module RecruitmentCycle
  def self.current_year
    if FeatureFlag.active?('switch_to_next_recruitment_cycle')
      2021
    else
      2020
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
