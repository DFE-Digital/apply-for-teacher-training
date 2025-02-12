require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.conditions_not_met' do
    let(:email) { described_class.conditions_not_met(application_choices.first) }
    let(:application_choices) do
      [build_stubbed(:application_choice, :conditions_not_met,
                     course_option:, current_course_option: course_option,
                     offer: build_stubbed(:offer, conditions: [build_stubbed(:text_condition, :unmet, description: 'Be cool')]))]
    end

    before { application_form }

    it_behaves_like(
      'a mail with subject and content',
      'You did not meet the offer conditions for Mathematics (M101) at Arithmetic College',
      'greeting' => 'Hello Fred',
      'course status' => 'Your application for Mathematics (M101) has been unsuccessful',
      'reason' => 'Arithmetic College have said that you do not meet these conditions of the offer they made to you:',
      'conditions' => 'Be cool',
      'next steps' => 'Unfortunately, you will not be able to join the course. Contact Arithmetic College if you need further advice.',
      'ske couse link' => 'https://getintoteaching.education.gov.uk/how-to-apply-for-teacher-training/subject-knowledge-enhancement',
      'git references url' => 'https://getintoteaching.education.gov.uk/how-to-apply-for-teacher-training/teacher-training-references',
    )
  end
end
