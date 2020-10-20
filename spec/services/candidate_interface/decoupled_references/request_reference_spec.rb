require 'rails_helper'

RSpec.describe CandidateInterface::DecoupledReferences::RequestReference do
  describe '#call' do
    let(:reference) { create(:reference, feedback_status: 'not_requested_yet') }
    let(:execute_service) { described_class.new.call(reference, flash) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let(:flash) { ActionDispatch::Flash::FlashHash.new }

    before do
      allow(RefereeMailer).to receive(:reference_request_email).and_return(mail)
      execute_service
    end

    it 'updates the references feeedback status to requested' do
      expect(reference.feedback_status).to eq('feedback_requested')
    end

    it 'sends a refeence request email to the referee mailer' do
      expect(RefereeMailer).to have_received(:reference_request_email).with(reference)
    end

    context 'when running in a provider sandbox', sandbox: true do
      it 'autocompletes the reference' do
        application_form = create(:application_form)
        application_form.application_references << build(:reference, email_address: 'refbot1@example.com')
        application_form.application_references << build(:reference, email_address: 'refbot2@example.com')
        application_form.application_references.reload

        described_class.new.call(application_form.application_references.first, flash)
        described_class.new.call(application_form.application_references.second, flash)

        application_form.application_references.reload.each do |reference|
          expect(reference.feedback).not_to be_nil
          expect(reference.feedback_status).to eq 'feedback_provided'
        end
      end
    end
  end
end
