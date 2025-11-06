require 'rails_helper'

module CandidateMailers
  RSpec.describe EnqueueVisaSponsorshipDeadlineReminderWorker do
    describe '#perform' do
      it 'calls SendVisaSponsorshipDeadlineReminderWorker worker' do
        create_list(:application_choice, 2)
        allow(ApplicationChoicesVisaSponsorshipDeadlineReminder).to(
          receive(:call).and_return(ApplicationChoice.all),
        )
        allow(SendVisaSponsorshipDeadlineReminderWorker).to receive(:perform_at)

        described_class.new.perform
        expect(SendVisaSponsorshipDeadlineReminderWorker).to have_received(:perform_at)
      end
    end
  end
end
