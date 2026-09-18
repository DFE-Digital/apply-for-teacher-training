require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.nudge_unsubmitted_with_incomplete_references' do
    context 'when the references section has not been completed' do
      let(:application_form) { create(:application_form, first_name: 'Fred') }
      let(:email) { described_class.nudge_unsubmitted_with_incomplete_references(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Give details of 2 people who can give references',
        'greeting' => 'Hello Fred',
        'content' => 'You have not completed the references section of your teacher training application yet',
        'professional strengths heading' => 'Understand your professional strengths',
      )

      it_behaves_like 'an email with unsubscribe option'

      context 'candidate has applied for a secondary course' do
        it 'renders adviser sign up text if not already assigned' do
          secondary_course = create(:course, :with_course_options, :secondary)
          create(:application_choice, course_option: secondary_course.course_options.first, application_form:)

          expect(email.body).to include('Get a teacher training adviser')
        end
      end
    end
  end

  describe 'tailored teacher training adviser text for "assigned" adviser status' do
    let(:application_form_with_adviser_eligibility) { create(:application_form_eligible_for_adviser, adviser_status: 'assigned') }

    subject(:email) { described_class.nudge_unsubmitted_with_incomplete_references(application_form_with_adviser_eligibility) }

    it 'refers to existing adviser' do
      expect(email.body).to have_text 'Your teacher training adviser can give advice on references.'
      expect(email.body).to have_text 'Contact our support team'
    end
  end
end
