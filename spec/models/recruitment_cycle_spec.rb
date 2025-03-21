require 'rails_helper'

RSpec.describe RecruitmentCycle, time: CycleTimetableHelper.mid_cycle(2023) do
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

  describe '.next_year?(year)' do
    context 'when year is next year' do
      it 'returns true' do
        expect(described_class.next_year?(CycleTimetable.next_year)).to be(true)
      end
    end

    context 'when year is this year' do
      it 'returns false' do
        expect(described_class.next_year?(CycleTimetable.current_year)).to be(false)
      end
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

  describe '#next_course_starting_range' do
    context 'after the apply deadline', time: after_apply_deadline(2024) do
      it 'returns the 2025-26 academic year' do
        expect(described_class.next_courses_starting_range).to eq '2025 to 2026'
      end
    end

    context 'after find opens, before apply opens', time: after_find_opens(2025) do
      it 'returns the 2025-26 academic year' do
        expect(described_class.next_courses_starting_range).to eq '2025 to 2026'
      end
    end

    context 'mid cycle 2025', time: mid_cycle(2025) do
      it 'returns the 2026-27 academic year' do
        expect(described_class.next_courses_starting_range).to eq '2026 to 2027'
      end
    end
  end

  describe '#next_apply_opening_date' do
    context 'after the apply deadline', time: after_apply_deadline(2024) do
      it 'returns the apply opening date for recruitment cycle 2025' do
        expect(described_class.next_apply_opening_date).to eq Time.zone.local(2024, 10, 8, 9)
      end
    end

    context 'after find opens, before apply opens', time: after_find_opens(2025) do
      it 'returns the apply opening date for recruitment cycle 2025' do
        expect(described_class.next_apply_opening_date).to eq Time.zone.local(2024, 10, 8, 9)
      end
    end

    context 'mid cycle', time: mid_cycle(2025) do
      it 'returns the apply opening date for recruitment cycle 2026' do
        expect(described_class.next_apply_opening_date).to eq Time.zone.local(2025, 10, 8, 9)
      end
    end
  end
end
