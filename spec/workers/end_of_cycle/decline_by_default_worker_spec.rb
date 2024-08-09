require 'rails_helper'

RSpec.describe EndOfCycle::DeclineByDefaultWorker do
  describe '#perform' do
    context 'for previous cycle, current cycle, next cycle' do
      [RecruitmentCycle.previous_year, RecruitmentCycle.current_year, RecruitmentCycle.next_year].each do |year|
        context 'after the decline by default date', time: decline_by_default_run_date(year) do
          it 'calls DeclineByDefaultService' do
            declineable = create(:application_choice, :offer)
            decline_service = spy
            allow(EndOfCycle::DeclineByDefaultService)
              .to receive(:new)
              .with(declineable.application_form)
              .and_return(decline_service)
            described_class.new.perform
            expect(decline_service).to have_received(:call)
          end

          it 'changes inactive application to declined by default' do
            declineable = create(:application_choice, :offer)
            described_class.new.perform

            expect(declineable.reload.status).to eq 'declined'
            expect(declineable.declined_by_default).to be true
          end
        end

        context 'between cycles, but not on decline by default date', time: after_apply_deadline(year) do
          it 'does not run DeclineByDefaultService' do
            declineable = create(:application_choice, :offer)

            described_class.new.perform

            expect(declineable.reload.status).to eq 'offer'
          end
        end

        context 'in mid-cycle', time: mid_cycle(year) do
          it 'does not run DeclineByDefaultService' do
            declineable = create(:application_choice, :offer)

            described_class.new.perform

            expect(declineable.reload.status).to eq 'offer'
          end
        end

        context 'after_apply_reopens', time: after_apply_reopens(year) do
          it 'does not run once the new cycle starts' do
            declineable = create(:application_choice, :offer)

            described_class.new.perform

            expect(declineable.reload.status).to eq 'offer'
          end
        end
      end
    end
  end
end
