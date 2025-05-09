require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.nudge_unsubmitted_with_incomplete_references' do
    context 'when the references section has not been completed' do
      let(:email) { described_class.nudge_unsubmitted_with_incomplete_references(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Give details of 2 people who can give references',
        'greeting' => 'Hello Fred',
        'content' => 'You have not completed the references section of your teacher training application yet',
        'realistic job preview heading' => 'Understand your professional strengths',
        'realistic job preview' => 'Try the realistic job preview tool',
        'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
      )

      it_behaves_like 'an email with unsubscribe option'

      it 'renders adviser sign up text if not already assigned' do
        expect(email.body).to include('A teacher training adviser can give advice on references:')
        expect(email.body).to include('Alternatively, call')
      end
    end
  end

  describe 'tailored teacher training adviser text for "assigned" adviser status' do
    let(:application_form_with_adviser_eligibility) { create(:application_form_eligible_for_adviser, adviser_status: 'assigned') }

    subject(:email) { described_class.nudge_unsubmitted_with_incomplete_references(application_form_with_adviser_eligibility) }

    it 'refers to existing adviser' do
      expect(email.body).to have_content 'Your teacher training adviser can give advice on references.'
      expect(email.body).to have_content 'Contact our support team'
    end
  end
end
