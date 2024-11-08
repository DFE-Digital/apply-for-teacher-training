require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.apply_to_multiple_courses_after_30_working_days' do
    let(:application_form) do
      create(
        :application_form,
        :minimum_info,
        first_name: 'Fred',
        application_choices: create_list(
          :application_choice,
          2,
          :inactive,
        ),
      )
    end

    let(:email) { described_class.apply_to_multiple_courses_after_30_working_days(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Increase your chances of receiving an offer for teacher training',
      'greeting' => 'Hello Fred',
      'content' => 'While you wait for a response on these applications, you can apply to 4 more courses at different training providers',
    )
  end
end
