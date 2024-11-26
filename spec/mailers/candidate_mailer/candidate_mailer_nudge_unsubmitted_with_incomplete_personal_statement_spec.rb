require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.nudge_unsubmitted_with_incomplete_courses' do
    let(:email) { described_class.nudge_unsubmitted_with_incomplete_personal_statement(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Get help with your personal statement',
      'greeting' => 'Hello Fred',
      'realistic job preview heading' => 'Understand your professional strengths',
      'realistic job preview' => 'Try the realistic job preview tool',
      'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
    )

    it_behaves_like 'an email with unsubscribe option'
  end
end
