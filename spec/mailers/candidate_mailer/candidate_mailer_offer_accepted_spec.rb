require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.offer_accepted' do
    let(:recruitment_cycle_year) { CycleTimetable.current_year }
    let(:candidate) { create(:candidate) }
    let(:application_form) do
      build_stubbed(:application_form, first_name: 'Fred',
                                       candidate:,
                                       recruitment_cycle_year:,
                                       application_choices:)
    end
    let(:email) { described_class.offer_accepted(application_form.application_choices.first) }
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
      'sign in link' => 'Sign in to your account',
    )

    it 'includes reference text' do
      expect(email.body).to include('you have met your offer conditions')
      expect(email.body).to include('check the progress of your reference requests')
    end
  end
end
