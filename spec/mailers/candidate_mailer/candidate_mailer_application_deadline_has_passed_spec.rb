require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.application_deadline_has_passed' do
    let(:email) { described_class.application_deadline_has_passed(application_form) }

    let(:timetable) { application_form.recruitment_cycle_timetable }
    let(:next_recruitment_cycle) { timetable.relative_next_timetable }
    let(:next_academic_year) { next_recruitment_cycle.academic_year_range_name }
    let(:apply_reopens_date) { next_recruitment_cycle.apply_reopens_at }

    it 'renders the content' do
      expect(email.subject).to eq('The application deadline has passed')
      expect(email.body).to include("Dear #{application_form.first_name}")
      expect(email.body).to include("The deadline for courses starting by the end of September #{timetable.recruitment_cycle_year} has passed.")
      expect(email.body).to include('What happens next?')
      expect(email.body).to include(
        "Update your details to get ready to apply for courses starting in the #{next_academic_year} academic year.",
      )
      expect(email.body).to include(
        "You will be able to apply for these courses from #{apply_reopens_date.to_fs(:govuk_date_time_time_first)}.",
      )
      expect(email.body).to include('Sign in to your account to update your details')
      expect(email.body).to include('Contact us')
      expect(email.body).to include(
        'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
      )
    end

    it_behaves_like 'an email with unsubscribe option'
  end
end
