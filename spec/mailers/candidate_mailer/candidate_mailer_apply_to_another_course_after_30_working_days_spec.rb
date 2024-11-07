require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper
  describe '.apply_to_another_course_after_30_working_days' do
    let(:application_form) do
      create(
        :application_form,
        :minimum_info,
        first_name: 'Fred',
        application_choices: [create(:application_choice, :inactive)],
      )
    end

    let(:email) { described_class.apply_to_another_course_after_30_working_days(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Increase your chances of receiving an offer for teacher training',
      'greeting' => 'Hello Fred',
      'content' => 'To give yourself the best chance of success, you can apply to another training provider',
    )
  end
end
