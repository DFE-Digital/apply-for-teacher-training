require 'rails_helper'

RSpec.describe EndOfCycleTimetable do
  let(:one_hour_before_apply1_deadline) { Time.zone.local(2020, 8, 24, 23, 0, 0) }
  let(:one_hour_after_apply1_deadline) { Time.zone.local(2020, 8, 25, 1, 0, 0) }
  let(:one_hour_before_apply2_deadline) { Time.zone.local(2020, 9, 18, 23, 0, 0) }
  let(:one_hour_after_apply2_deadline) { Time.zone.local(2020, 9, 19, 1, 0, 0) }
  let(:one_hour_after_2021_cycle_opens) { Time.zone.local(2020, 10, 13, 1, 0, 0) }

  describe '.show_apply_1_deadline_banner?' do
    it 'returns true before the configured date' do
      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be true
      end
    end

    it 'returns false after the configured date' do
      Timecop.travel(one_hour_after_apply1_deadline) do
        expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be false
      end
    end
  end

  describe '.show_apply_2_deadline_banner?' do
    it 'returns true before the configured date' do
      Timecop.travel(one_hour_before_apply2_deadline) do
        expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be true
      end
    end

    it 'returns false after the configured date' do
      Timecop.travel(one_hour_after_apply2_deadline) do
        expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be false
      end
    end
  end

  describe '.between_cycles_apply_1?' do
    it 'returns false before the configured date' do
      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(EndOfCycleTimetable.between_cycles_apply_1?).to be false
      end
    end

    it 'returns true after the configured date' do
      Timecop.travel(one_hour_after_apply1_deadline) do
        expect(EndOfCycleTimetable.between_cycles_apply_1?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(EndOfCycleTimetable.between_cycles_apply_1?).to be false
      end
    end
  end

  describe '.between_cycles_apply_2?' do
    it 'returns false before the configured date' do
      Timecop.travel(one_hour_before_apply2_deadline) do
        expect(EndOfCycleTimetable.between_cycles_apply_2?).to be false
      end
    end

    it 'returns true after the configured date' do
      Timecop.travel(one_hour_after_apply2_deadline) do
        expect(EndOfCycleTimetable.between_cycles_apply_2?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(EndOfCycleTimetable.between_cycles_apply_2?).to be false
      end
    end
  end

  describe '.next_cycle_year' do
    it 'returns 2021 when in 2020 cycle' do
      Timecop.travel(Time.zone.local(2020, 8, 24, 23, 0, 0)) do
        expect(EndOfCycleTimetable.next_cycle_year).to eq 2021
      end
    end
  end

  describe '.find_down?' do
    it 'returns false before find closes' do
      Timecop.travel(EndOfCycleTimetable.find_closes.beginning_of_day - 1.hour) do
        expect(EndOfCycleTimetable.find_down?).to be false
      end
    end

    it 'returns false after find_reopens' do
      Timecop.travel(EndOfCycleTimetable.find_reopens.end_of_day + 1.hour) do
        expect(EndOfCycleTimetable.find_down?).to be false
      end
    end

    it 'returns true between find_closes and find_reopens' do
      Timecop.travel(EndOfCycleTimetable.find_closes.end_of_day + 1.hour) do
        expect(EndOfCycleTimetable.find_down?).to be true
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
        expect(EndOfCycleTimetable.stop_applications_to_unavailable_course_options?).to be true
      end
    end

    it 'is false when before the window' do
      Timecop.travel(Time.zone.local(2020, 9, 7).end_of_day - 1.minute) do
        expect(EndOfCycleTimetable.stop_applications_to_unavailable_course_options?).to be false
      end
    end

    it 'is false when after the window' do
      Timecop.travel(Time.zone.local(2020, 10, 13).beginning_of_day) do
        expect(EndOfCycleTimetable.stop_applications_to_unavailable_course_options?).to be false
      end
    end
  end

  describe 'can_add_course_choice?' do
    let(:execute_service) { described_class.can_add_course_choice?(application_form) }

    context 'application form is in the apply1 state' do
      let(:application_form) { build_stubbed(:application_form) }

      context 'when the date is after the apply1 submission deadline' do
        it 'returns false' do
          Timecop.travel(EndOfCycleTimetable.apply_1_deadline + 1.day) do
            expect(execute_service).to eq false
          end
        end
      end

      context 'when the date is before the apply1 submission deadline' do
        it 'returns true' do
          Timecop.travel(EndOfCycleTimetable.apply_1_deadline) do
            expect(execute_service).to eq true
          end
        end
      end

      context 'when the date is post find reopening' do
        it 'returns true' do
          Timecop.travel(EndOfCycleTimetable.find_reopens) do
            expect(execute_service).to eq true
          end
        end
      end
    end

    context 'application form is in the apply again state' do
      let(:application_form) { build_stubbed(:application_form, phase: :apply_2) }

      context 'when the date is after the apply again submission deadline' do
        it 'returns false' do
          Timecop.travel(EndOfCycleTimetable.apply_2_deadline + 1.day) do
            expect(execute_service).to eq false
          end
        end
      end

      context 'when the date is before the apply again submission deadline' do
        it 'returns true' do
          Timecop.travel(EndOfCycleTimetable.apply_2_deadline) do
            expect(execute_service).to eq true
          end
        end
      end

      context 'when the date is post find reopening' do
        it 'returns true' do
          Timecop.travel(EndOfCycleTimetable.apply_reopens) do
            expect(execute_service).to eq true
          end
        end
      end
    end

    context 'application form is from a previous recruitment cycle' do
      let(:application_form) { build_stubbed(:application_form, recruitment_cycle_year: 2020) }

      it 'returns false' do
        Timecop.travel('2021-02-03') do
          expect(execute_service).to eq false
        end
      end
    end
  end

  describe '.can_submit?' do
    before { allow(RecruitmentCycle).to receive(:current_year).and_return(2021) }

    it 'returns true for an application in the current recruitment cycle' do
      application_form = build :application_form, recruitment_cycle_year: 2021
      expect(described_class.can_submit?(application_form)).to be true
    end

    it 'returns false for an application in the previous recruitment cycle' do
      application_form = build :application_form, recruitment_cycle_year: 2020
      expect(described_class.can_submit?(application_form)).to be false
    end
  end
end
