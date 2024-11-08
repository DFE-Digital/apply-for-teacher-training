require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.nudge_unsubmitted_with_incomplete_courses' do
    let(:email) { described_class.nudge_unsubmitted_with_incomplete_courses(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Get help choosing a teacher training course',
      'greeting' => 'Hello Fred',
    )
  end
end
