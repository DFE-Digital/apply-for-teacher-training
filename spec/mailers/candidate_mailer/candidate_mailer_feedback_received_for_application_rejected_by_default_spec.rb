require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  before do
    magic_link_stubbing(candidate)
  end

  describe '.feedback_received_for_application_rejected_by_default' do
    let(:candidate) { build(:candidate) }
    let(:application_form) { build(:application_form, first_name: 'Fred', candidate:, application_choices:) }
    let(:application_choices) do
      [build_stubbed(:application_choice,
                     :rejected_by_default_with_feedback,
                     course_option:,
                     current_course_option: course_option,
                     rejection_reason: 'I\'m so happy')]
    end

    context 'candidate has been awarded a place on a course or has applied again since' do
      let(:choice) { application_form.application_choices.first }
      let(:email) { described_class.feedback_received_for_application_rejected_by_default(choice, true) }

      it_behaves_like(
        'a mail with subject and content',
        'Feedback on your application for Arithmetic College',
        'heading' => 'Dear Fred',
        'provider name' => 'Arithmetic College',
        'name and code for course' => 'Mathematics (M101)',
        'feedback' => 'I\'m so happy',
      )

      it 'encourages candidate to apply again' do
        expect(email.body).to include('use your feedback to strengthen your application and apply again')
      end
    end

    context 'candidate did not get a place on any of their courses and has not applied again since' do
      let(:choice) { application_form.application_choices.first }
      let(:email) { described_class.feedback_received_for_application_rejected_by_default(choice, false) }

      it_behaves_like(
        'a mail with subject and content',
        'Feedback on your application for Arithmetic College',
        'heading' => 'Dear Fred',
        'provider name' => 'Arithmetic College',
        'name and code for course' => 'Mathematics (M101)',
        'feedback' => 'I\'m so happy',
      )

      it 'does not encourage candidate to apply again' do
        expect(email.body).not_to include('If this feedback was useful, consider using it to strengthen your application and apply again:')
      end
    end
  end
end
