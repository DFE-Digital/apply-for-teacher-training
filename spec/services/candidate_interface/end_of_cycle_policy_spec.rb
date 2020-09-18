require 'rails_helper'

RSpec.describe CandidateInterface::EndOfCyclePolicy do
  describe '#can_add_course_choice?' do
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
  end

  describe 'cancel_application_because_option_unavailable?(application_choice)' do
    context 'the EOC timetable says we should be stopping applications' do
      before do
        allow(EndOfCycleTimetable)
          .to receive(:stop_applications_to_unavailable_course_options?)
          .and_return(true)
      end

      it 'is true if the course option is full ' do
        application_choice = create(
          :application_choice,
          course_option: create(:course_option, :no_vacancies),
        )

        expect(described_class.cancel_application_because_option_unavailable?(application_choice)).to eq true
      end

      it 'is true if the course is withdrawn' do
        application_choice = create(
          :application_choice,
          course_option: create(:course_option, course: create(:course, withdrawn: true)),
        )

        expect(described_class.cancel_application_because_option_unavailable?(application_choice)).to eq true
      end

      it 'is false if the course option is still available' do
        application_choice = create(
          :application_choice,
          course_option: create(:course_option),
        )

        expect(described_class.cancel_application_because_option_unavailable?(application_choice)).to eq false
      end
    end

    context 'the EOC timetable says we should not be stopping applications' do
      before do
        allow(EndOfCycleTimetable)
          .to receive(:stop_applications_to_unavailable_course_options?)
          .and_return(false)
      end

      it 'is false if the course option is full ' do
        application_choice = create(
          :application_choice,
          course_option: create(:course_option, :no_vacancies),
        )

        expect(described_class.cancel_application_because_option_unavailable?(application_choice)).to eq false
      end

      it 'is false if the course is withdrawn' do
        application_choice = create(
          :application_choice,
          course_option: create(:course_option, course: create(:course, withdrawn: true)),
        )

        expect(described_class.cancel_application_because_option_unavailable?(application_choice)).to eq false
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
