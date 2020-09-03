require 'rails_helper'

RSpec.describe RecruitmentCycle do
  describe '.current_year' do
    it 'is 2020' do
      expect(RecruitmentCycle.current_year).to eq(2020)
    end

    it 'can be changed to the next cycle using a feature flag' do
      FeatureFlag.activate('switch_to_next_recruitment_cycle')
      expect(RecruitmentCycle.current_year).to eq(2021)
    end
  end
end
