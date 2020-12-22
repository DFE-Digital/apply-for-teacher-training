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

  describe '.current_cycle_name' do
    it 'is current year to the following year' do
      Timecop.travel(Time.zone.local(2020, 1, 1, 1, 0, 0)) do
        expect(RecruitmentCycle.current_cycle_name).to eq('2020 to 2021')
      end
    end
  end

  describe '.next_cycle_name' do
    it 'is next year to the following year by default' do
      Timecop.travel(Time.zone.local(2020, 1, 1, 1, 0, 0)) do
        expect(RecruitmentCycle.next_cycle_name).to eq('2021 to 2022')
      end
    end
  end

  describe '.cycle_name' do
    it 'defaults to current year to the following year' do
      Timecop.travel(Time.zone.local(2020, 1, 1, 1, 0, 0)) do
        expect(RecruitmentCycle.cycle_name).to eq('2020 to 2021')
      end
    end

    it 'is the argument year to the following year' do
      expect(RecruitmentCycle.cycle_name(2019)).to eq('2019 to 2020')
    end
  end
end
