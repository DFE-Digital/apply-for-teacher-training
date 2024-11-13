require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.nudge_unsubmitted' do
    let(:email) { described_class.nudge_unsubmitted(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Get last-minute advice about your teacher training application',
      'greeting' => 'Dear Fred',
    )

    it_behaves_like 'an email with unsubscribe option'
  end
end
