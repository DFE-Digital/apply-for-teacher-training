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
        timetable.christmas_holiday_range = timetable.find_opens_at - 3.days..timetable.christmas_holiday_range.last

        expect(timetable.valid?).to be false
        expect(timetable.errors[:christmas_holiday_range]).to eq ['Christmas holiday range should be within cycle']
      end

      it 'validates christmas range includes christmas day' do
        timetable = build(:recruitment_cycle_timetable)
        timetable.christmas_holiday_range =
          timetable.christmas_holiday_range.last..timetable.christmas_holiday_range.last + 10.days

        expect(timetable.valid?).to be false
        expect(timetable.errors[:christmas_holiday_range])
          .to eq ['Christmas holiday range should include Christmas day']
      end
    end

    describe 'validates easter range' do
      it 'validates easter range is within cycle' do
        timetable = build(:recruitment_cycle_timetable)
        timetable.easter_holiday_range = timetable.easter_holiday_range.last..timetable.find_closes_at + 2.days

        expect(timetable.valid?).to be false
        expect(timetable.errors[:easter_holiday_range]).to eq ['Easter holiday range should be within cycle']
      end

      it 'validates easter range includes Easter Day' do
        timetable = build(:recruitment_cycle_timetable)
        timetable.easter_holiday_range =
          timetable.easter_holiday_range.last..timetable.easter_holiday_range.last + 10.days

        expect(timetable.valid?).to be false
        expect(timetable.errors[:easter_holiday_range]).to eq ['Easter holiday range should include easter']
      end
    end

    describe 'validates sequential order of dates' do
      it 'validates apply opens after find opens' do
        timetable = build(:recruitment_cycle_timetable)
        timetable.find_opens_at = timetable.apply_opens_at + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:apply_opens_at]).to eq ['Apply opens after find opens']
      end

      it 'validates apply deadline is after apply opens' do
        timetable = build(:recruitment_cycle_timetable)
        timetable.apply_opens_at = timetable.apply_deadline_at + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:apply_deadline_at]).to eq ['Apply deadline must be after apply opens']
      end

      it 'validates reject by default is after apply deadline' do
        timetable = build(:recruitment_cycle_timetable)
        timetable.apply_deadline_at = timetable.reject_by_default_at + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:reject_by_default_at]).to eq ['Reject by default must be after the apply deadline']
      end
    end
  end

  describe '#current_timetable' do
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
end
