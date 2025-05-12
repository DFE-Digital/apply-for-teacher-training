require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.new_interview' do
    let(:application_choice_with_interview) { build_stubbed(:application_choice, course_option:, application_form:) }
    let(:interview) do
      build_stubbed(:interview,
                    date_and_time: Time.zone.local(current_year, 1, 15, 9, 30),
                    location: 'Hogwarts Castle',
                    additional_details: 'Bring your magic wand for the spells test',
                    provider: course_option.provider,
                    application_choice: application_choice_with_interview)
    end
    let(:email) { described_class.new_interview(application_choice_with_interview, interview) }

    it_behaves_like(
      'a mail with subject and content',
      'Interview arranged for Mathematics (M101)',
      'greeting' => 'Dear Fred',
      'details' => 'Arithmetic College has arranged an interview with you for Mathematics (M101).',
      'interview date' => "15 January #{current_year}",
      'interview time' => '9:30am',
      'interview location' => 'Hogwarts Castle',
      'additional interview details' => 'Bring your magic wand for the spells test',
      'TTA header' => 'Prepare for your interview',
      'TTA content' => 'Do you have a teacher training adviser yet?',
      'TTA link' => 'Get a teacher training adviser',
    )
  end
end
