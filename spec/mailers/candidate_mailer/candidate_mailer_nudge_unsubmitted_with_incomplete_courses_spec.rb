require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.nudge_unsubmitted_with_incomplete_courses' do
    let(:email) { described_class.nudge_unsubmitted_with_incomplete_courses(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Get help choosing a teacher training course',
      'greeting' => 'Hello Fred',
      'realistic job preview heading' => 'Gain insights into life as a teacher',
      'realistic job preview' => 'Try the realistic job preview tool',
      'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
    )

    it_behaves_like 'an email with unsubscribe option'

    it 'renders adviser sign up text if not already assigned' do
      expect(email.body).to include('A teacher training adviser could help you choose a course, if you are not sure about what you would like to teach.')
      expect(email.body).to include('Alternatively, call')
    end
  end

  describe 'tailored teacher training adviser text for "assigned" adviser status' do
    let(:application_form_with_adviser_eligibility) { create(:application_form_eligible_for_adviser, adviser_status: 'assigned') }

    subject(:email) { described_class.nudge_unsubmitted_with_incomplete_courses(application_form_with_adviser_eligibility) }

    it 'refers to existing adviser' do
      expect(email.body).to have_text 'Your teacher training adviser could help you choose a course, if you are not sure about what you would like to teach.'
      expect(email.body).to have_text 'Contact our support team'
    end
  end

  describe 'bursary information' do
    it 'renders bursary and scholarship information for british candidates' do
      eligible_form = create(:application_form, first_nationality: 'British')
      email = described_class.nudge_unsubmitted(eligible_form)
      expect(email.body).to have_text 'Some subjects and courses have bursaries of up to £29,000 and scholarships of up to £31,000. These courses fill up more quickly than other courses.'
    end

    it 'does not render bursary and scholarship information for international candidates' do
      ineligible_form = create(:application_form, first_nationality: 'American', second_nationality: nil)
      email = described_class.nudge_unsubmitted(ineligible_form)
      expect(email.body).to have_no_text 'Some subjects and courses have bursaries of up to £29,000 and scholarships of up to £31,000. These courses fill up more quickly than other courses.'
    end
  end
end
