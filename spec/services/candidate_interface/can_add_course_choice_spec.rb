require 'rails_helper'

RSpec.describe CandidateInterface::CanAddCourseChoice do
  describe '#can_add_course_choice?' do
    let(:execute_service) { described_class.can_add_course_choice?(application_form: application_form) }

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
          Timecop.travel(EndOfCycleTimetable.apply_1_deadline - 1.day) do
            expect(execute_service).to eq true
          end
        end
      end

      context 'when the date is post find reopening' do
        it 'returns true' do
          Timecop.travel(EndOfCycleTimetable.find_reopens + 1.day) do
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
          Timecop.travel(EndOfCycleTimetable.apply_2_deadline - 1.day) do
            expect(execute_service).to eq true
          end
        end
      end

      context 'when the date is post find reopening' do
        it 'returns true' do
          Timecop.travel(EndOfCycleTimetable.find_reopens + 1.day) do
            expect(execute_service).to eq true
          end
        end
      end
    end
  end
end
