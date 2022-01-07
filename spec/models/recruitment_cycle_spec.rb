require 'rails_helper'

RSpec.describe RecruitmentCycle do
  describe '.cycle_string' do
    it 'throws an error when a cycle does not exist for the specified year' do
      expect { described_class.cycle_string(2000) }
        .to raise_error(KeyError)
    end

    it 'formats the displayed cycle string' do
      expect(described_class.cycle_string(described_class.previous_year))
        .to eq("#{described_class.previous_year - 1} to #{described_class.previous_year}")
    end

    it 'indicates the current cycle' do
      expect(described_class.cycle_string(described_class.current_year))
        .to eq("#{described_class.previous_year} to #{described_class.current_year} - current")
    end
  end

  describe '.current_year' do
    it 'delegates to CycleTimetable' do
      allow(CycleTimetable).to receive(:current_year)

      described_class.current_year

      expect(CycleTimetable).to have_received(:current_year)
    end
  end

  describe '.next_year' do
    it 'delegates to CycleTimetable' do
      allow(CycleTimetable).to receive(:next_year).and_return(2020)

      described_class.next_year

      expect(CycleTimetable).to have_received(:next_year)
    end
  end

  describe '.previous_year' do
    it 'is 2019 if the current year is 2020' do
      allow(CycleTimetable).to receive(:current_year).and_return(2020)

      expect(described_class.previous_year).to eq(2019)
    end
  end

  describe '.cycle_name' do
    it 'defaults from current year to the following year' do
      allow(CycleTimetable).to receive(:current_year).and_return(2020)

      expect(described_class.cycle_name).to eq('2019 to 2020')
    end

    it 'is from argument(year) to the following year' do
      expect(described_class.cycle_name(2021)).to eq('2020 to 2021')
    end
  end

  describe '.verbose_cycle_name' do
    it 'defaults from current year to the following year' do
      allow(CycleTimetable).to receive(:current_year).and_return(2020)

      expect(described_class.verbose_cycle_name).to eq('October 2019 to September 2020')
    end

    it 'is from argument(year) to the following year' do
      expect(described_class.verbose_cycle_name(2021)).to eq('October 2020 to September 2021')
    end
  end
end
