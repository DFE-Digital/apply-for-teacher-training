require 'rails_helper'

RSpec.describe CycleTimetableQuery do
  let(:one_hour_before_apply1_deadline) { Time.zone.local(2020, 8, 24, 23, 0, 0) }
  let(:one_hour_after_apply1_deadline) { Time.zone.local(2020, 8, 25, 1, 0, 0) }
  let(:one_hour_before_apply2_deadline) { Time.zone.local(2020, 9, 18, 23, 0, 0) }
  let(:one_hour_after_apply2_deadline) { Time.zone.local(2020, 9, 19, 1, 0, 0) }
  let(:one_hour_after_2021_cycle_opens) { Time.zone.local(2020, 10, 13, 1, 0, 0) }

  describe '.show_apply_1_deadline_banner?' do
    it 'returns true before the configured date' do
      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(CycleTimetableQuery.show_apply_1_deadline_banner?).to be true
      end
    end

    it 'returns false after the configured date' do
      Timecop.travel(one_hour_after_apply1_deadline) do
        expect(CycleTimetableQuery.show_apply_1_deadline_banner?).to be false
      end
    end
  end

  describe '.show_apply_2_deadline_banner?' do
    it 'returns true before the configured date' do
      Timecop.travel(one_hour_before_apply2_deadline) do
        expect(CycleTimetableQuery.show_apply_2_deadline_banner?).to be true
      end
    end

    it 'returns false after the configured date' do
      Timecop.travel(one_hour_after_apply2_deadline) do
        expect(CycleTimetableQuery.show_apply_2_deadline_banner?).to be false
      end
    end
  end

  describe '.between_cycles_apply_1?' do
    it 'returns false before the configured date' do
      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(CycleTimetableQuery.between_cycles_apply_1?).to be false
      end
    end

    it 'returns true after the configured date' do
      Timecop.travel(one_hour_after_apply1_deadline) do
        expect(CycleTimetableQuery.between_cycles_apply_1?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(CycleTimetableQuery.between_cycles_apply_1?).to be false
      end
    end
  end

  describe '.between_cycles_apply_2?' do
    it 'returns false before the configured date' do
      Timecop.travel(one_hour_before_apply2_deadline) do
        expect(CycleTimetableQuery.between_cycles_apply_2?).to be false
      end
    end

    it 'returns true after the configured date' do
      Timecop.travel(one_hour_after_apply2_deadline) do
        expect(CycleTimetableQuery.between_cycles_apply_2?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(CycleTimetableQuery.between_cycles_apply_2?).to be false
      end
    end
  end

  describe '.next_cycle_year' do
    it 'returns 2021 when in 2020 cycle' do
      Timecop.travel(Time.zone.local(2020, 8, 24, 23, 0, 0)) do
        expect(CycleTimetableQuery.next_cycle_year).to eq 2021
      end
    end
  end

  describe '.find_down?' do
    it 'returns false before find closes' do
      Timecop.travel(CycleTimetableQuery.find_closes.beginning_of_day - 1.hour) do
        expect(CycleTimetableQuery.find_down?).to be false
      end
    end

    it 'returns false after find_reopens' do
      Timecop.travel(CycleTimetableQuery.find_reopens.end_of_day + 1.hour) do
        expect(CycleTimetableQuery.find_down?).to be false
      end
    end

    it 'returns true between find_closes and find_reopens' do
      Timecop.travel(CycleTimetableQuery.find_closes.end_of_day + 1.hour) do
        expect(CycleTimetableQuery.find_down?).to be true
      end
    end
  end

  describe '.current_cycle?' do
    def create_application_for(recruitment_cycle_year)
      create :application_form, recruitment_cycle_year: recruitment_cycle_year
    end

    it 'returns true for an application for courses in the current cycle' do
      expect(
        described_class.current_cycle?(create_application_for(RecruitmentCycle.current_year)),
      ).to be true
    end

    it 'returns false for an application for courses in the previous cycle' do
      expect(
        described_class.current_cycle?(create_application_for(RecruitmentCycle.previous_year)),
      ).to be false
    end
  end

  describe 'stop_applications_to_unavailable_course_options?' do
    it 'is true when between "stop_applications_to_unavailable_course_options" and "apply_reopens"' do
      Timecop.travel(Time.zone.local(2020, 9, 7).end_of_day + 1.minute) do
        expect(CycleTimetableQuery.stop_applications_to_unavailable_course_options?).to be true
      end
    end

    it 'is false when before the window' do
      Timecop.travel(Time.zone.local(2020, 9, 7).end_of_day - 1.minute) do
        expect(CycleTimetableQuery.stop_applications_to_unavailable_course_options?).to be false
      end
    end

    it 'is false when after the window' do
      Timecop.travel(Time.zone.local(2020, 10, 13).beginning_of_day) do
        expect(CycleTimetableQuery.stop_applications_to_unavailable_course_options?).to be false
      end
    end
  end
end
