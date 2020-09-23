require 'rails_helper'

RSpec.describe CandidateInterface::CancelReferenceAtEndOfCycle do
  describe '#call' do
    let(:application_reference) { create(:reference, :requested) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    before do
      allow(RefereeMailer).to receive(:reference_cancelled_email).and_return(mail)
    end

    it 'cancels a reference at the end of the cycle' do
      described_class.call(application_reference)

      expect(application_reference.feedback_status).to eq 'cancelled_at_end_of_cycle'
      expect(RefereeMailer).to have_received(:reference_cancelled_email).with(application_reference)
      expect(mail).to have_received(:deliver_later)
    end
  end
end
