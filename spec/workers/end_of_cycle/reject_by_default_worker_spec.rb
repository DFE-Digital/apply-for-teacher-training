require 'rails_helper'

RSpec.describe EndOfCycle::RejectByDefaultWorker do
  describe '#perform' do
    context 'for previous cycle, current cycle, next cycle' do
      [RecruitmentCycle.previous_year, RecruitmentCycle.current_year, RecruitmentCycle.next_year].each do |year|
        context 'after the reject by default date', time: reject_by_default_run_date(year) do
          it 'calls EndOfCycleRejectByDefaultService' do
            rejection_service = spy
            rejectable = create(:application_choice, :inactive)
            allow(EndOfCycle::RejectByDefaultService).to receive(:new).with(rejectable.application_form).and_return(rejection_service)
            described_class.new.perform

            expect(rejection_service).to have_received(:call)
          end

          it 'changes rejectable application to rejected by default' do
            inactive_choice = create(:application_choice, :inactive)
            interviewing_choice = create(:application_choice, :interviewing)
            awaiting_decision_choice = create(:application_choice, :awaiting_provider_decision)
            offered_choice = create(:application_choice, :offer)

            described_class.new.perform

            expect(inactive_choice.reload.status).to eq('rejected')
            expect(inactive_choice.rejected_by_default).to be(true)
            expect(interviewing_choice.reload.status).to eq('rejected')
            expect(interviewing_choice.rejected_by_default).to be(true)
            expect(awaiting_decision_choice.reload.status).to eq('rejected')
            expect(awaiting_decision_choice.rejected_by_default).to be(true)

            expect(offered_choice.reload.status).to eq('offer')
            expect(offered_choice.rejected_by_default).to be(false)
          end
        end

        context 'between cycles, but not on reject by default date', time: after_apply_deadline(year) do
          it 'does not run RejectionByDefaultService' do
            rejectable = create(:application_choice, :inactive)

            task = described_class.new.perform

            expect(task).to eq []
            expect(rejectable.reload.status).to eq 'inactive'
          end
        end

        context 'in mid-cycle', time: mid_cycle(year) do
          it 'does not run RejectionByDefaultService' do
            rejectable = create(:application_choice, :inactive)

            task = described_class.new.perform

            expect(task).to eq []
            expect(rejectable.reload.status).to eq 'inactive'
          end
        end

        context 'after_apply_reopens', time: after_apply_reopens(year) do
          it 'does not run once the new cycle starts' do
            rejectable = create(:application_choice, :inactive)

            task = described_class.new.perform

            expect(task).to eq []
            expect(rejectable.reload.status).to eq 'inactive'
          end
        end
      end
    end
  end
end
