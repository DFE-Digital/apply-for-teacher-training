require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.interview_updated', time: mid_cycle do
    let(:application_choice_with_interview) { build_stubbed(:application_choice, course_option:, application_form:) }
    let(:interview) do
      build_stubbed(:interview,
                    date_and_time: Time.zone.local(RecruitmentCycleTimetable.current_year, 1, 15, 9, 30),
                    location: 'Hogwarts Castle',
                    additional_details: 'Bring your magic wand for the spells test',
                    provider: course_option.provider,
                    application_choice: application_choice_with_interview)
    end

    context 'when the course has been updated' do
      let(:previous_course) { create(:course, name: 'Geography', code: 'G100') }
      let(:email) { described_class.interview_updated(application_choice_with_interview, interview, previous_course) }

      it_behaves_like(
        'a mail with subject and content',
        'Interview details updated for Geography (G100)',
        'greeting' => 'Dear Fred',
        'details' => 'The details of your interview for Geography (G100) have been updated.',
        'interview with new course details' => 'The interview is with Arithmetic College.',
        'new course' => 'It is now for Mathematics (M101).',
        'interview date' => "15 January #{RecruitmentCycleTimetable.current_year}",
        'interview time' => '9:30am',
        'interview location' => 'Hogwarts Castle',
        'additional interview details' => 'Bring your magic wand for the spells test',
      )
    end

    context 'when course is not changed and previous course is nil' do
      it 'the email does not contain any new course details' do
        email = described_class.interview_updated(application_choice_with_interview, interview, nil)
        expect(email.body).not_to include('It is now for Mathematics (M101).')
      end
    end

    context 'when additional details is nil' do
      it 'the email does not contain any additional details' do
        interview.additional_details = nil
        email = described_class.interview_updated(application_choice_with_interview, interview, nil)
        expect(email.body).not_to include('Bring your magic wand for the spells test')
        expect(email.body).not_to include('Additional details:')
      end
    end
  end
end
