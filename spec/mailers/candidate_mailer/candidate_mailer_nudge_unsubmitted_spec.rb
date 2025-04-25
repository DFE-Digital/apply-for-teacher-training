require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.nudge_unsubmitted' do
    let(:email) { described_class.nudge_unsubmitted(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Get last-minute advice about your teacher training application',
      'greeting' => 'Dear Fred',
      'realistic job preview heading' => 'Gain insights into life as a teacher',
      'realistic job preview' => 'Try the realistic job preview tool',
      'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
    )

    it_behaves_like 'an email with unsubscribe option'

    it 'renders adviser sign up text if not already assigned' do
      expect(email.body).to include('A teacher training adviser could help with your application, if something is holding you back from submitting it. They can talk to you about teacher training and teaching as a career.')
      expect(email.body).to include('Alternatively, call')
    end
  end

  describe 'tailored teacher training adviser text for "assigned" adviser status' do
    let(:application_form_with_adviser_eligibility) { create(:application_form_eligible_for_adviser, adviser_status: 'assigned') }

    subject(:email) { described_class.nudge_unsubmitted(application_form_with_adviser_eligibility) }

    it 'refers to existing adviser' do
      expect(email.body).to have_content 'Your teacher training adviser can help with your application, if something is holding you back from submitting it. They can talk to you about teacher training and teaching as a career.'
      expect(email.body).to have_content 'Contact our support team'
    end
  end
end
