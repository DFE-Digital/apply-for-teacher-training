require 'rails_helper'

RSpec.describe RecruitmentCycleTimetable do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:recruitment_cycle_year) }
    it { is_expected.to validate_presence_of(:find_opens_at) }
    it { is_expected.to validate_presence_of(:apply_opens_at) }
    it { is_expected.to validate_presence_of(:apply_deadline_at) }
    it { is_expected.to validate_presence_of(:reject_by_default_at) }
    it { is_expected.to validate_presence_of(:decline_by_default_at) }
    it { is_expected.to validate_presence_of(:find_closes_at) }
    it { is_expected.to validate_uniqueness_of(:recruitment_cycle_year) }

    describe 'validates sequential order of dates' do
      it 'validates apply opens after find opens' do
        timetable = SupportInterface::RecruitmentCycleTimetableGenerator.generate_next_year
        timetable.find_opens_at = timetable.apply_opens_at + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:apply_opens_at]).to eq ['Enter an Apply open date that is after Find has opened']
      end

      it 'validates apply deadline is after apply opens' do
        timetable = SupportInterface::RecruitmentCycleTimetableGenerator.generate_next_year
        timetable.apply_opens_at = timetable.apply_deadline_at + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:apply_deadline_at]).to eq ['Enter an Apply deadline that is after Apply has opened']
      end

      it 'validates reject by default is after apply deadline' do
        timetable = SupportInterface::RecruitmentCycleTimetableGenerator.generate_next_year
        timetable.apply_deadline_at = timetable.reject_by_default_at + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:reject_by_default_at]).to eq ['Enter a reject by default date that is after the Apply deadline']
      end
    end
  end

  describe 'scopes' do
    describe '.current_and_past' do
      it 'returns timetables that are not in the future' do
        first_timetable = described_class.all.order(:recruitment_cycle_year).first
        next_timetable = described_class.next_timetable
        current_timetable = described_class.current_timetable

        results = described_class.current_and_past
        expect(results).to include(first_timetable, current_timetable)
        expect(results).not_to include(next_timetable)
      end
    end
  end

  describe '.current_and_past_years' do
    it 'returns recruitment cycle years that are not in the future' do
      years = described_class.current_and_past_years
      current_year = described_class.current_year
      expect(years).to include(current_year, current_year - 1)
      expect(years.any? { |year| year > current_year }).to be false
    end
  end

  describe '.current_timetable' do
    context 'mid-cycle' do
      it 'returns the correct timetable' do
        mid_cycle = described_class.find_by(recruitment_cycle_year: 2022).apply_opens_at
        travel_temporarily_to(mid_cycle) do
          expect(described_class.current_timetable.recruitment_cycle_year).to eq 2022
        end
      end
    end

    context 'after find closes, before find reopens in the next cycle' do
      it 'returns the correct timetable' do
        after_find_closes = described_class.find_by(recruitment_cycle_year: 2023).find_closes_at + 2.hours
        travel_temporarily_to(after_find_closes) do
          expect(described_class.current_timetable.recruitment_cycle_year).to eq 2023
        end
      end
    end

    context 'before apply opens' do
      it 'returns the correct timetable' do
        after_find_reopens = described_class.find_by(recruitment_cycle_year: 2023).find_closes_at + 9.5.hours

        travel_temporarily_to(after_find_reopens) do
          expect(described_class.current_timetable.recruitment_cycle_year).to eq 2024
        end
      end
    end
  end

  describe '.next_timetable' do
    it 'returns the timetable after the current one' do
      next_year = described_class.current_year + 1
      expect(described_class.next_timetable).to eq described_class.find_by(recruitment_cycle_year: next_year)
    end
  end

  describe '.previous_timetable' do
    it 'returns the timetable before the current one' do
      previous_year = described_class.current_year - 1
      expect(described_class.previous_timetable).to eq described_class.find_by(recruitment_cycle_year: previous_year)
    end
  end

  describe '.last_timetable' do
    it 'returns the last available timetable' do
      last_year = described_class.pluck(:recruitment_cycle_year).max
      expect(described_class.last_timetable.recruitment_cycle_year).to eq last_year
    end
  end

  describe '.current_cycle_week' do
    context 'the first day of the cycle' do
      it 'returns 1' do
        travel_temporarily_to(described_class.current_timetable.find_opens_at + 1.second) do
          expect(described_class.current_cycle_week).to eq 1
        end
      end
    end

    context 'sunday after find opens' do
      it 'is the first week of the cycle' do
        travel_temporarily_to(described_class.current_timetable.find_opens_at.sunday) do
          expect(described_class.current_cycle_week).to eq 1
        end
      end
    end

    context 'monday after find opens' do
      it 'is the second week of the cycle' do
        travel_temporarily_to(described_class.current_timetable.find_opens_at.sunday + 1.day) do
          expect(described_class.current_cycle_week).to eq 2
        end
      end
    end

    context 'after find closes, before it reopens' do
      it 'returns last week in cycle' do
        travel_temporarily_to(described_class.current_timetable.find_closes_at + 1.second) do
          expect(described_class.current_cycle_week).to eq 53
        end
      end
    end
  end

  describe '.find_cycle_week_by_datetime' do
    it 'returns the expected week' do
      datetime = Time.zone.local(2023, 11, 20)
      expect(described_class.find_cycle_week_by_datetime(datetime)).to eq 8
    end
  end

  describe '.years_visible_in_support' do
    context 'in production' do
      before do
        allow(HostingEnvironment).to receive(:production?).and_return true
      end

      it 'only returns up to the current year' do
        result = described_class.years_visible_in_support

        expect(result.max).to eq described_class.current_year
        expect(result.min).to eq 2019
      end
    end

    context 'not in production' do
      before do
        allow(HostingEnvironment).to receive(:production?).and_return false
      end

      it 'returns up to the next cycle year' do
        result = described_class.years_visible_in_support

        expect(result.max).to eq described_class.next_year
        expect(result.min).to eq 2019
      end
    end
  end

  describe '.years_visible_to_providers' do
    it 'returns last year and this year' do
      current_year = described_class.current_year
      expect(described_class.years_visible_to_providers).to eq [current_year - 1, current_year]
    end
  end

  describe '.this_day_last_cycle' do
    context '2 days after apply opens this cycle' do
      it 'returns 2 days after apply opens last cycle' do
        TestSuiteTimeMachine.travel_temporarily_to(described_class.current_timetable.apply_opens_at + 2.days) do
          result = described_class.this_day_last_cycle
          previous_timetable = described_class.previous_timetable
          expect(result.to_date).to eq (previous_timetable.apply_opens_at + 2.days).to_date
        end
      end
    end
  end

  describe '#apply_open?' do
    context 'mid cycle', time: before_apply_deadline do
      it 'returns true' do
        timetable = described_class.current_timetable
        expect(timetable.apply_open?).to be true
      end
    end

    context 'before apply opens', time: after_find_opens do
      it 'returns false' do
        timetable = described_class.current_timetable
        expect(timetable.apply_open?).to be false
      end
    end

    context 'after the apply deadline', time: after_apply_deadline do
      it 'returns false' do
        timetable = described_class.current_timetable
        expect(timetable.apply_open?).to be false
      end
    end
  end

  describe '#cycle_range_name' do
    it 'returns a string describing the recruitment cycle year range' do
      timetable = described_class.find_by(recruitment_cycle_year: 2024)
      expect(timetable.cycle_range_name).to eq '2023 to 2024'
    end
  end

  describe '#cycle_range_name_with_current_indicator' do
    it 'returns year range with "current"' do
      TestSuiteTimeMachine.travel_temporarily_to(DateTime.new(2024, 8, 8)) do
        current_timetable = described_class.current_timetable
        next_timetable = described_class.next_timetable
        expect(current_timetable.cycle_range_name_with_current_indicator).to eq '2023 to 2024 - current'
        expect(next_timetable.cycle_range_name_with_current_indicator).to eq '2024 to 2025'
      end
    end
  end

  describe '#next_available_academic_year_range' do
    context 'after the apply deadline', time: after_apply_deadline do
      it 'returns academic year range for the next timetable' do
        timetable = described_class.current_timetable
        result = timetable.next_available_academic_year_range
        expect(result).to eq described_class.next_timetable.academic_year_range_name
      end
    end

    context 'before apply deadline', time: mid_cycle do
      it 'returns year range for the current timetable' do
        timetable = described_class.current_timetable
        result = timetable.next_available_academic_year_range
        expect(result).to eq described_class.current_timetable.academic_year_range_name
      end
    end
  end

  describe '#previously_closed_academic_year_range' do
    context 'after apply deadline has passed', time: after_apply_deadline do
      it 'returns the academic year range for the current timetable' do
        timetable = described_class.current_timetable
        result = timetable.previously_closed_academic_year_range
        expect(result).to eq timetable.academic_year_range_name
      end
    end

    context 'before apply deadline has passed', time: mid_cycle do
      it 'returns the academic year range for the previous timetable' do
        timetable = described_class.current_timetable
        result = timetable.previously_closed_academic_year_range
        expect(result).to eq timetable.relative_previous_timetable.academic_year_range_name
      end
    end
  end

  describe '#apply_reopens_at' do
    context 'in the time between find opening and apply opens', time: after_find_opens do
      it 'returns the apply opens date for the current timetable' do
        timetable = described_class.current_timetable
        result = timetable.apply_reopens_at

        expect(result).to eq timetable.apply_opens_at
      end
    end

    context 'after apply has opened in the current year', time: mid_cycle do
      it 'returns the apply open date for the next year' do
        timetable = described_class.current_timetable
        result = timetable.apply_reopens_at

        expect(result).to eq timetable.relative_next_timetable.apply_opens_at
      end
    end
  end

  describe '#between_cycles?' do
    context 'mid cycle', time: mid_cycle do
      it 'returns false' do
        timetable = described_class.current_timetable
        expect(timetable.between_cycles?).to be false
      end
    end

    context 'before apply opens', time: after_find_opens do
      it 'returns true' do
        timetable = described_class.current_timetable
        expect(timetable.between_cycles?).to be true
      end
    end

    context 'after the apply deadline', time: after_apply_deadline do
      it 'returns true' do
        timetable = described_class.current_timetable
        expect(timetable.between_cycles?).to be true
      end
    end
  end

  describe '#next_year?' do
    it 'returns true when the timetable is for the next recruitment cycle' do
      current_timetable = described_class.current_timetable
      expect(current_timetable.next_year?).to be false

      next_timetable = described_class.next_timetable
      expect(next_timetable.next_year?).to be true
    end
  end

  describe '#current_year?' do
    it 'returns true when the timetable is for the current recruitment cycle' do
      current_timetable = described_class.current_timetable
      expect(current_timetable.current_year?).to be true

      next_timetable = described_class.next_timetable
      expect(next_timetable.current_year?).to be false
    end
  end

  describe '#previous_year?' do
    it 'returns true when the timetable is for the previous recruitment cycle' do
      current_timetable = described_class.current_timetable
      expect(current_timetable.previous_year?).to be false

      previous_timetable = described_class.previous_timetable
      expect(previous_timetable.previous_year?).to be true
    end
  end

  describe '#relative_next_timetable' do
    it 'returns nil if no next timetable exists' do
      timetable = described_class.all.order(:recruitment_cycle_year).last
      expect(timetable.relative_next_timetable).to be_nil
    end

    it 'returns the timetable with the next consecutive cycle year if it exists' do
      timetable = described_class.current_timetable
      expect(timetable.relative_next_timetable.recruitment_cycle_year).to eq timetable.recruitment_cycle_year + 1
    end
  end

  describe '#relative_next_year' do
    it 'returns the next year' do
      timetable = described_class.all.order(:recruitment_cycle_year).last
      expect(timetable.relative_next_year).to eq timetable.recruitment_cycle_year + 1
    end
  end

  describe '#realtive_previous_year' do
    it 'returns the previous year relative to the instantiated timetable' do
      timetable = described_class.all.order(:recruitment_cycle_year).first
      expect(timetable.relative_previous_year).to eq timetable.recruitment_cycle_year - 1
    end
  end

  describe '#relative_previous_timetable' do
    it 'returns nil if no previous timetable exists' do
      timetable = described_class.all.order(:recruitment_cycle_year).first
      expect(timetable.relative_previous_timetable).to be_nil
    end

    it 'returns the timetable with the next consecutive cycle year if it exists' do
      timetable = described_class.current_timetable
      expect(timetable.relative_previous_timetable.recruitment_cycle_year).to eq timetable.recruitment_cycle_year - 1
    end
  end

  describe '#show_banners_at' do
    it 'returns a date 12 weeks before the application deadline' do
      timetable = described_class.current_timetable
      expect(timetable.show_banners_at).to eq timetable.apply_deadline_at - 12.weeks
    end
  end
end
