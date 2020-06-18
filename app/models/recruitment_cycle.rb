module RecruitmentCycle
  def self.current_year
    if FeatureFlag.active?('switch_to_2021_recruitment_cycle')
      2021
    else
      2020
    end
  end
end
