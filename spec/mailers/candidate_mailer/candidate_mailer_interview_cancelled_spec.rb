require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.interview_cancelled' do
    let(:application_choice_with_interview) { build_stubbed(:application_choice, course_option:, application_form:) }
    let(:interview) do
      build_stubbed(:interview,
                    date_and_time: Time.zone.local(CycleTimetable.current_year, 1, 15, 9, 30),
                    location: 'Hogwarts Castle',
                    additional_details: 'Bring your magic wand for the spells test',
                    provider: course_option.provider,
                    application_choice: application_choice_with_interview)
    end

    let(:email) { described_class.interview_cancelled(application_choice_with_interview, interview, 'We recruited someone else') }

    it_behaves_like(
      'a mail with subject and content',
      'Interview cancelled - Arithmetic College',
      'greeting' => 'Dear Fred',
      'details' => "Arithmetic College has cancelled your interview on 15 January #{CycleTimetable.current_year} at 9:30am",
      'cancellation reason' => 'We recruited someone else',
    )
  end
end
