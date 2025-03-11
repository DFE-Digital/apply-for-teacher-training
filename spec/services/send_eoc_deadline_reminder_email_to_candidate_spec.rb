require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidate do
  describe '#call' do
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let(:application_form) { create(:application_form) }

    it 'sends a reminder email to the candidate and creates and EOC chaser' do
      %w[eoc_first_deadline_reminder eoc_second_deadline_reminder].each do |chaser_type|
        allow(CandidateMailer).to receive(chaser_type).and_return(mail)
        described_class.new(application_form:, chaser_type:).call

        expect(application_form.chasers_sent.send(chaser_type).count).to eq(1)
        expect(CandidateMailer).to have_received(chaser_type).with(application_form)
      end
    end
  end
end
