require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.duplicate_account_locked' do
    let(:email) { described_class.duplicate_account_locked(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Your new Apply for teacher training account has been locked',
      'greeting' => 'Dear Fred',
      'details' => 'We’ve found that you already have an account, so we’ve locked the new one.',
      'support' => 'contact us at becomingateacher@digital.education.gov.uk',
      'contact us' => 'Contact us',
    )
  end

  describe '.duplicate_account_original_account_sign_in' do
    let(:email) { described_class.duplicate_account_original_account_sign_in(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Use this email address to sign in to Apply for teacher training',
      'greeting' => 'Dear Fred',
      'details' => 'You recently created a new Apply for teacher training account using a different email address. The new account has been locked.',
      'sign in link' => 'Sign in to your original account here: http://localhost:3000/candidate/account',
      'support' => 'If you did not create another account or you cannot sign in',
    )
  end
end
