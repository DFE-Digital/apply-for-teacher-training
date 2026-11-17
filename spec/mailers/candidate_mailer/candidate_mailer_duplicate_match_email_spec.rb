require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.duplicate_match_email' do
    context 'when the candidate has a duplicate account regardless of whether it is submitted or unsubmitted' do
      let(:email) { described_class.duplicate_match_email(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Your new Apply for teacher training account has been locked',
        'greeting' => 'Dear Fred',
        'details' => 'You recently created a new Apply for teacher training account using this email address.',
        'locked' => 'We’ve found that you already have an account, so we’ve locked the new one.',
        'original account' => 'We’ve sent an email to the address linked to your original account with a link to sign in.',
        'support' => 'If you cannot access your original account or its email address, contact us at becomingateacher@digital.education.gov.uk.',
      )
    end
  end
end
