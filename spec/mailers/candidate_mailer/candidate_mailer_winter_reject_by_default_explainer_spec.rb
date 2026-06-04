require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.winter_reject_by_default_explainer' do
    let(:email) { described_class.winter_reject_by_default_explainer(application_form) }
    let(:timetable) { application_form.recruitment_cycle_timetable }
    let(:this_academic_year) { timetable.previously_closed_academic_year_range }
    let(:next_academic_year) { timetable.next_available_academic_year_range }

    it_behaves_like(
      'a mail with subject and content',
      'Your application has been rejected automatically',
      'greeting' => 'Dear Fred',
      'cause' => 'This is because the provider did not respond before their deadline. If you have any questions about this, please contact the provider.',
      'what happens next' => 'What happens next?',
      'sign in' => 'Sign in to your account to apply for courses',
      'contact us' => 'Contact us',
      'contact details' => 'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
    )

    it 'renders content for application rejected automatically' do
      expect(email.body).to include(
        "Your application for teacher training starting in the  #{this_academic_year} academic year has been rejected automatically.",
      )
    end

    it 'renders content for open courses' do
      expect(email.body).to include(
        "Courses are open for applications for courses starting in the #{next_academic_year} academic year.",
      )
    end
  end
end
