require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.reject_by_default_explainer' do
    let(:email) { described_class.reject_by_default_explainer(application_form) }
    let(:timetable) { application_form.recruitment_cycle_timetable }
    let(:next_academic_year_range) { timetable.next_available_academic_year_range }
    let(:next_recruitment_cycle_year) { timetable.relative_next_year }
    let(:apply_reopens_date) { timetable.apply_reopens_at.to_fs(:govuk_date_time_time_first) }

    it_behaves_like(
      'a mail with subject and content',
      'Your application has been rejected automatically',
      'greeting' => 'Dear Fred',
      'details' => "Your application for teacher training starting by the end of September #{current_timetable.recruitment_cycle_year} has been rejected automatically.",
      'cause' => 'This is because the provider did not respond before their deadline. If you have any questions about this, please contact the provider.',
      'what happens next' => 'What happens next?',
      'sign in' => 'Sign in to your account to update your details',
      'contact us' => 'Contact us',
      'contact details' => 'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
    )

    it 'renders content for updating the recipients details' do
      expect(email.body).to include(
        "You can update your details to get ready to apply for courses starting in the #{next_academic_year_range} academic year.",
      )
    end

    it 'renders content for applying for courses' do
      expect(email.body).to include(
        "You will be able to apply to these courses from #{apply_reopens_date}.",
      )
    end
  end
end
