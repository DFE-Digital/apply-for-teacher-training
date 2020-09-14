require 'rails_helper'

RSpec.describe CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications do
  describe '#call' do
    let!(:application_choice1) { create(:awaiting_references_application_choice) }

    before do
      create(
        :application_choice,
        :awaiting_references,
        application_form: create(:application_form, recruitment_cycle_year: RecruitmentCycle.next_year),
      )
      create(:application_choice, :with_offer)
    end

    context 'between the apply_2_deadline and the new cycle launching' do
      it 'returns application forms in the awaiting reference state' do
        Timecop.travel(EndOfCycleTimetable.apply_2_deadline + 1.day) do
          expect(described_class.call).to eq [application_choice1.application_form]
        end
      end
    end

    context 'before the apply2 deadline' do
      it 'returns []' do
        Timecop.travel(EndOfCycleTimetable.apply_2_deadline - 1.day) do
          expect(described_class.call).to eq []
        end
      end
    end

    context 'after the new cycle has launched' do
      it 'returns []' do
        Timecop.travel(EndOfCycleTimetable.apply_reopens + 1.day) do
          expect(described_class.call).to eq []
        end
      end
    end
  end
end
