require 'rails_helper'

RSpec.describe RecruitmentCycle do
  describe '.current_year' do
    it 'delegates to ECycleTimetable' do
      allow(CycleTimetable).to receive(:current_year)

      RecruitmentCycle.current_year

      expect(CycleTimetable).to have_received(:current_year)
    end
  end

  describe '.next_year' do
    it 'is 2021 if the current year is 2020' do
      allow(CycleTimetable).to receive(:current_year).and_return(2020)

      expect(RecruitmentCycle.next_year).to eq(2021)
    end
  end

  describe '.previous_year' do
    it 'is 2019 if the current year is 2020' do
      allow(CycleTimetable).to receive(:current_year).and_return(2020)

      expect(RecruitmentCycle.previous_year).to eq(2019)
    end
  end

  describe '.cycle_name' do
    it 'defaults from current year to the following year' do
      allow(CycleTimetable).to receive(:current_year).and_return(2020)

      expect(RecruitmentCycle.cycle_name).to eq('2019 to 2020')
    end

    it 'is from argument(year) to the following year' do
      expect(RecruitmentCycle.cycle_name(2021)).to eq('2020 to 2021')
    end
  end
end
