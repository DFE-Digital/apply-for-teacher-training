require 'rails_helper'

RSpec.describe CancelReferee do
  describe '#call' do
    let(:reference) { create(:reference, feedback_status: 'feedback_requested') }
    let(:execute_service) { described_class.new.call(reference: reference) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let(:message) { "Candidate #{reference.application_form.first_name} has cancelled one of their references" }
    let(:url) { Rails.application.routes.url_helpers.support_interface_application_form_url(reference.application_form) }

    before do
      allow(RefereeMailer).to receive(:reference_cancelled_email).and_return(mail)
      allow(SlackNotificationWorker).to receive(:perform_async).and_return(true)
      execute_service
    end

    it 'updates the references feeedback status to cancelled' do
      expect(reference.feedback_status).to eq('cancelled')
    end

    it 'sends a cancel reference email request to the referee mailer' do
      expect(RefereeMailer).to have_received(:reference_cancelled_email).with(reference)
    end

    it 'sends a the slack notification worker' do
      expect(SlackNotificationWorker).to have_received(:perform_async).with(message, url)
    end
  end
end
