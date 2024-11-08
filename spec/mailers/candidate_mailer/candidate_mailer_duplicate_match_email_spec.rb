require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.duplicate_match_email' do
    context 'when the candidate has a duplicate account regardless of whether it is submitted or unsubmitted' do
      let(:email) { described_class.duplicate_match_email(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'You created more than one account to apply for teacher training',
        'greeting' => 'Dear Fred',
        'details' => 'You created more than one account to apply for teacher training. Your accounts have been locked.',
      )
    end
  end
end
