require 'rails_helper'

RSpec.describe RecruitmentCycle do
  describe '.current_year' do
    it 'is 2020 before the end of cycle' do
      Timecop.travel(Time.zone.local(2020, 1, 1, 12, 0, 0)) do
        expect(RecruitmentCycle.current_year).to eq(2020)
      end
    end

    it 'is 2021 in the new cycle' do
      Timecop.travel(Time.zone.local(2020, 11, 1, 12, 0, 0)) do
        expect(RecruitmentCycle.current_year).to eq(2021)
      end
    end
  end
end
