require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidate do
  describe '#call' do
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let(:application_form) { create(:application_form) }

    it 'sends a reminder email to the candidate and creates and EOC chaser' do
      allow(CandidateMailer).to receive(:eoc_deadline_reminder).and_return(mail)
      described_class.call(application_form: application_form)

      expect(application_form.chasers_sent.eoc_deadline_reminder.count).to eq(1)
      expect(CandidateMailer).to have_received(:eoc_deadline_reminder).with(application_form)
    end
  end
end
