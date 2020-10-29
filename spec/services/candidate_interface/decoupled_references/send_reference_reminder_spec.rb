require 'rails_helper'

RSpec.describe CandidateInterface::DecoupledReferences::SendReferenceReminder do
  around do |example|
    Timecop.freeze(Time.zone.local(2020, 10, 21)) do
      example.run
    end
  end

  describe '.call' do
    let(:reference) { create(:reference, feedback_status: 'feedback_requested', name: 'Evo Morales') }
    let(:flash) { {} }
    let(:execute_service) { described_class.call(reference, flash) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let(:message) { "Candidate #{reference.application_form.first_name} has sent a reminder to Evo" }
    let(:url) { Rails.application.routes.url_helpers.support_interface_application_form_url(reference.application_form) }

    before do
      allow(RefereeMailer).to receive(:reference_request_chaser_email).and_return(mail)
      allow(SlackNotificationWorker).to receive(:perform_async).and_return(true)
      execute_service
    end

    it 'updates the reference to record when the reminder was sent' do
      expect(reference.reminder_sent_at).to eq(Time.zone.now)
    end

    it 'sends a reference chaser request to the referee mailer' do
      expect(RefereeMailer).to have_received(:reference_request_chaser_email).with(reference.application_form, reference)
    end

    it 'sends a message and url to the Slack notification worker' do
      expect(SlackNotificationWorker).to have_received(:perform_async).with(message, url)
    end
  end
end
