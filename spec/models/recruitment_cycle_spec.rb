require 'rails_helper'

RSpec.describe RecruitmentCycle do
  describe '.current_year' do
    it 'delegates to EndOfCycleTimetable' do
      allow(EndOfCycleTimetable).to receive(:current_year)

      RecruitmentCycle.current_year

      expect(EndOfCycleTimetable).to have_received(:current_year)
    end
  end

  describe '.next_year' do
    it 'is 2021' do
      Timecop.travel(Time.zone.local(2020, 1, 1, 12, 0, 0)) do
        expect(RecruitmentCycle.next_year).to eq(2021)
      end
    end
  end

  describe '.previous_year' do
    it 'is 2019' do
      Timecop.travel(Time.zone.local(2020, 1, 1, 12, 0, 0)) do
        expect(RecruitmentCycle.previous_year).to eq(2019)
      end
    end
  end

  describe '.cycle_name' do
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
