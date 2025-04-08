require 'rails_helper'

RSpec.describe EndOfCycle::RejectByDefaultWorker do
  describe '#perform' do
    context 'when force is true' do
      it 'enqueues the secondary worker', time: mid_cycle do
        rejectable = create(:application_choice, :inactive)

        allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
        described_class.new.perform(force: true)
        expect(EndOfCycle::RejectByDefaultSecondaryWorker)
          .to have_received(:perform_at).with(kind_of(Time), [rejectable.application_form.id])
      end
    end

    context 'for previous cycle, current cycle' do
      [previous_year, current_year].each do |year|
        context 'after the reject by default date', time: reject_by_default_run_date(year) do
          it 'enqueues the secondary worker' do
            inactive_choice = create(:application_choice, :inactive)
            interviewing_choice = create(:application_choice, :interviewing)
            awaiting_decision_choice = create(:application_choice, :awaiting_provider_decision)

            # It will not include the offered application choice
            create(:application_choice, :offer)

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker)
              .to have_received(:perform_at)
                    .with(
                      kind_of(Time),
                      contain_exactly(
                        inactive_choice.application_form.id,
                        interviewing_choice.application_form.id,
                        awaiting_decision_choice.application_form.id,
                      ),
                    )
          end
        end

        context 'between cycles, but not on reject by default date', time: after_apply_deadline(year) do
          it 'does not enqueue the secondary worker' do
            create(:application_choice, :inactive)

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker).not_to have_received(:perform_at)
          end
        end

        context 'in mid-cycle', time: mid_cycle(year) do
          it 'does not enqueue the secondary worker' do
            create(:application_choice, :inactive)

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker).not_to have_received(:perform_at)
          end
        end

        context 'after_apply_reopens', time: after_apply_reopens(year) do
          it 'does not enqueue the secondary worker' do
            create(:application_choice, :inactive)

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker).not_to have_received(:perform_at)
          end
        end
      end
    end
  end
end
