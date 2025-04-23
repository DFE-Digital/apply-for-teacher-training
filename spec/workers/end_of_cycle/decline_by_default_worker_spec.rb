require 'rails_helper'

RSpec.describe EndOfCycle::DeclineByDefaultWorker do
  describe '#perform' do
    context 'where force is true' do
      it 'enqueues secondary worker for offered application choices', time: mid_cycle do
        declineable = create(:application_choice, :offer)

        allow(EndOfCycle::DeclineByDefaultSecondaryWorker).to receive(:perform_at)
        described_class.new.perform(true)
        expect(EndOfCycle::DeclineByDefaultSecondaryWorker)
          .to have_received(:perform_at).with(kind_of(Time), [declineable.application_form.id])
      end
    end

    context 'for previous cycle, current cycle' do
      [previous_year, current_year].each do |year|
        context 'after the decline by default date', time: decline_by_default_run_date(year) do
          it 'enqueues secondary worker for offered application choices' do
            declineable = create(:application_choice, :offer)

            allow(EndOfCycle::DeclineByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::DeclineByDefaultSecondaryWorker)
              .to have_received(:perform_at).with(kind_of(Time), contain_exactly(declineable.application_form.id))
          end
        end

        context 'between cycles, but not on decline by default date', time: after_apply_deadline(year) do
          it 'does not enqueues secondary worker' do
            create(:application_choice, :offer)

            allow(EndOfCycle::DeclineByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::DeclineByDefaultSecondaryWorker).not_to have_received(:perform_at)
          end
        end

        context 'in mid-cycle', time: mid_cycle(year) do
          it 'does not enqueues secondary worker' do
            create(:application_choice, :offer)

            allow(EndOfCycle::DeclineByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::DeclineByDefaultSecondaryWorker).not_to have_received(:perform_at)
          end
        end

        context 'after_apply_reopens', time: after_apply_reopens(year) do
          it 'does not enqueues secondary worker' do
            create(:application_choice, :offer)

            allow(EndOfCycle::DeclineByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::DeclineByDefaultSecondaryWorker).not_to have_received(:perform_at)
          end
        end
      end
    end
  end
end
