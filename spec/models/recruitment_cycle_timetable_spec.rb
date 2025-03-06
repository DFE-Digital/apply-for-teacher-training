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

    describe 'validates christmas range' do
      it 'validates christmas range is within cycle' do
        timetable = build(:recruitment_cycle_timetable)
        year = timetable.recruitment_cycle_year
        timetable.christmas_holiday_range = timetable.find_opens_at - 3.days..Time.zone.local(year, 1, 2)

        expect(timetable.valid?).to be false
        expect(timetable.errors[:christmas_holiday_range]).to eq ['Enter a Christmas holiday within cycle']
      end

      it 'validates christmas range includes christmas day' do
        timetable = build(:recruitment_cycle_timetable)
        year = timetable.recruitment_cycle_year - 1
        timetable.christmas_holiday_range = (Time.zone.local(year, 12, 26)...Time.zone.local(year, 12, 29))

        expect(timetable.valid?).to be false
        expect(timetable.errors[:christmas_holiday_range])
          .to eq ['Enter a Christmas holiday range that includes Christmas day']
      end
    end

    describe 'validates easter range' do
      it 'validates easter range is within cycle' do
        # We need one where we know where Easter is
        timetable = described_class.find_by(recruitment_cycle_year: 2024)
        timetable.easter_holiday_range = timetable.easter_holiday_range.last..timetable.find_closes_at + 2.days

        expect(timetable.valid?).to be false
        expect(timetable.errors[:easter_holiday_range]).to eq ['Enter an Easter holiday range within cycle']
      end

      it 'validates easter range includes Easter Day' do
        timetable = described_class.find_by(recruitment_cycle_year: 2024)
        timetable.easter_holiday_range =
          timetable.easter_holiday_range.last..timetable.easter_holiday_range.last + 10.days

        expect(timetable.valid?).to be false
        expect(timetable.errors[:easter_holiday_range]).to eq ['Enter an Easter holiday range that includes Easter']
      end
    end

    describe 'validates sequential order of dates' do
      it 'validates apply opens after find opens' do
        timetable = build(:recruitment_cycle_timetable, recruitment_cycle_year: 2050)
        timetable.find_opens_at = timetable.apply_opens_at + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:apply_opens_at]).to eq ['Enter an Apply open date that is after Find has opened']
      end

      it 'validates apply deadline is after apply opens' do
        timetable = build(:recruitment_cycle_timetable, recruitment_cycle_year: 2050)
        timetable.apply_opens_at = timetable.apply_deadline_at + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:apply_deadline_at]).to eq ['Enter an Apply deadline that is after Apply has opened']
      end

      it 'validates reject by default is after apply deadline' do
        timetable = build(:recruitment_cycle_timetable, recruitment_cycle_year: 2050)
        timetable.apply_deadline_at = timetable.reject_by_default_at + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:reject_by_default_at]).to eq ['Enter a reject by default date that is after the Apply deadline']
      end
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

  describe '#cycle_range_name' do
    it 'returns a string describing the recruitment cycle year range' do
      timetable = described_class.find_by(recruitment_cycle_year: 2024)
      expect(timetable.cycle_range_name).to eq '2023 to 2024'
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
