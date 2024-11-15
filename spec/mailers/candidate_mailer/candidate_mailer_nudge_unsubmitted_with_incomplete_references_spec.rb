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
      )

      it_behaves_like 'an email with unsubscribe option'
    end
  end
end
