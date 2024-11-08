require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.unconditional_offer_accepted' do
    let(:email) { described_class.unconditional_offer_accepted(application_form.application_choices.first) }
    let(:application_choices) do
      [build_stubbed(
        :application_choice,
        status: 'pending_conditions',
        course_option:,
        current_course_option: course_option,
      )]
    end

    it_behaves_like(
      'a mail with subject and content',
      'You have accepted Arithmetic College’s offer to study Mathematics (M101)',
      'greeting' => 'Hello Fred',
      'offer_details' => 'You have accepted Arithmetic College’s offer to study Mathematics (M101)',
      'sign in link' => 'Sign into your account',
    )
  end
end
