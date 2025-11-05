require 'rails_helper'

module CandidateMailers
  RSpec.describe SendVisaSponsorshipDeadlineChangeWorker do
    describe '#perform' do
      it 'sends visa sponsorship deadline change email' do
        application_choice = create(:application_choice)
        mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to(
          receive(:visa_sponsorship_deadline_change).and_return(mailer),
        )

        described_class.new.perform([application_choice.id])
        expect(mailer).to have_received(:deliver_later)
      end
    end
  end
end
