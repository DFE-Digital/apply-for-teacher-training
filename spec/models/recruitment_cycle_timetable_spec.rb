require 'rails_helper'

RSpec.describe RecruitmentCycleTimetable do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:recruitment_cycle_year) }
    it { is_expected.to validate_presence_of(:find_opens) }
    it { is_expected.to validate_presence_of(:apply_opens) }
    it { is_expected.to validate_presence_of(:apply_deadline) }
    it { is_expected.to validate_presence_of(:reject_by_default) }
    it { is_expected.to validate_presence_of(:decline_by_default) }
    it { is_expected.to validate_presence_of(:find_closes) }
    it { is_expected.to validate_uniqueness_of(:recruitment_cycle_year) }

    describe 'validates sequential order of dates' do
      it 'validates apply opens after find opens' do
        timetable = build(:recruitment_cycle_timetable)
        timetable.find_opens = timetable.apply_opens + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:apply_opens]).to eq ['Apply opens after find opens']
      end

      it 'validates apply deadline is after apply opens' do
        timetable = build(:recruitment_cycle_timetable)
        timetable.apply_opens = timetable.apply_deadline + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:apply_deadline]).to eq ['Apply deadline must be after apply opens']
      end

      it 'validates reject by default is after apply deadline' do
        timetable = build(:recruitment_cycle_timetable)
        timetable.apply_deadline = timetable.reject_by_default + 1.day

        expect(timetable.valid?).to be false
        expect(timetable.errors[:reject_by_default]).to eq ['Reject by default must be after the apply deadline']
      end
    end
  end
end
