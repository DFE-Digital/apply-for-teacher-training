require 'rails_helper'

module CandidateMailers
  RSpec.describe EnqueueVisaSponsorshipDeadlineReminderWorker do
    describe '#perform' do
      it 'calls SendVisaSponsorshipDeadlineReminderWorker worker' do
        create_list(:application_choice, 2)
        allow(ApplicationChoicesVisaSponsorshipDeadlineReminder).to(
          receive(:call).and_return(ApplicationChoice.all),
        )
        worker = instance_double(ActiveJob::ConfiguredJob)
        allow(SendVisaSponsorshipDeadlineReminderWorker).to receive(:set).and_return(worker)
        allow(worker).to receive(:perform_later)

        described_class.new.perform
        expect(SendVisaSponsorshipDeadlineReminderWorker).to have_received(:set)
        expect(worker).to have_received(:perform_later).with(ApplicationChoice.all.pluck(:id))
      end
    end
  end
end
