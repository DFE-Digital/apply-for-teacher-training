require 'rails_helper'

module CandidateMailers
  RSpec.describe EnqueueVisaSponsorshipDeadlineReminderWorker do
    describe '#perform' do
      it 'calls SendVisaSponsorshipDeadlineReminderWorker worker' do
        create_list(:application_choice, 2)
        allow(ApplicationChoicesVisaSponsorshipDeadlineReminder).to(
          receive(:call).and_return(ApplicationChoice.all),
        )
        expect {described_class.perform_now }.to enqueue_job(SendVisaSponsorshipDeadlineReminderWorker).with(ApplicationChoice.all.pluck(:id))
      end
    end
  end
end
