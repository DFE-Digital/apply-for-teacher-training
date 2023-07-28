require 'rails_helper'

RSpec.describe RecruitmentCycle, time: CycleTimetableHelper.mid_cycle(2023) do
  describe '.cycle_string' do
    it 'throws an error when a cycle does not exist for the specified year' do
      expect { described_class.cycle_string(2000) }
        .to raise_error(KeyError)
    end

    it 'formats the display for 2023' do
      expect(described_class.cycle_string(2023)).not_to be_blank
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

  describe '.years_visible_in_support' do
    context 'when in production hosting environment' do
      it 'returns correct array of years', hosting_env: 'production' do
        expect(described_class.years_visible_in_support).to contain_exactly(2023, 2022, 2021, 2020, 2019)
      end
    end

    context 'when in staging hosting environment' do
      it 'returns correct array of years', hosting_env: 'staging' do
        expect(described_class.years_visible_in_support).to contain_exactly(2024, 2023, 2022, 2021, 2020, 2019)
      end
    end
  end

  describe '.years_available_to_register' do
    it 'returns correct array of years' do
      expect(described_class.years_available_to_register).to contain_exactly(2023, 2022, 2021, 2020, 2019)
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
