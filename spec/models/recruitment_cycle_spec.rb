require 'rails_helper'

RSpec.describe RecruitmentCycle do
  describe '.current_year' do
    it 'is 2020 before the end of cycle' do
      allow(EndOfCycleTimetable).to receive(:current_year).and_return(2020)

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

  describe '.cycle_name' do
    before do
      allow(EndOfCycleTimetable).to receive(:current_year).and_return(2020)
    end

    it 'defaults to current year to the following year' do
      Timecop.travel(Time.zone.local(2020, 1, 1, 1, 0, 0)) do
        expect(RecruitmentCycle.cycle_name).to eq('2019 to 2020')
      end
    end

    it 'is the argument year to the following year' do
      expect(RecruitmentCycle.cycle_name(2021)).to eq('2020 to 2021')
    end
  end
end
