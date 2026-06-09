require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.respond_to_offer_before_deadline' do
    let(:email) { described_class.respond_to_offer_before_deadline(application_form) }

    let(:timetable) { application_form.recruitment_cycle_timetable }
    let(:this_academic_year) { timetable.previously_closed_academic_year_range }
    let(:next_academic_year) { timetable.next_available_academic_year_range }
    let(:apply_reopens_date) { timetable.apply_reopens_at.to_fs(:govuk_date_time_time_first) }

    it 'renders the content' do
      expect(email.subject).to eq("Accept your place on a teacher training course by #{timetable.decline_by_default_at.to_fs(:govuk_date_time_time_first)}")
      expect(email.body).to include("Dear #{application_form.first_name}")
      expect(email.body).to include('You have been offered a place on a teacher training course.')
      expect(email.body).to include("If you want to accept this place, you must do so by #{timetable.decline_by_default_at.to_fs(:govuk_date_time_time_first)}.")
      expect(email.body).to include('Sign in to your account to review your offer')
      expect(email.body).to include('Your other applications')
      expect(email.body).to include("Your other applications for teacher training starting in September #{timetable.recruitment_cycle_year} have been automatically rejected.")
      expect(email.body).to include('This is because the provider did not respond before their deadline. If you have any questions about this, please contact the provider.')
      expect(email.body).to include('If you do not accept your offer')
      expect(email.body).to include("You can update your details to get ready to apply for courses starting in the #{next_academic_year} academic year.")
      expect(email.body).to include("You will be able to apply for these courses from #{apply_reopens_date}.")
      expect(email.body).to include('Sign in to your account to update your details')
      expect(email.body).to include('Contact us')
      expect(email.body).to include(
        'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
      )
    end

    it_behaves_like 'an email with unsubscribe option'
  end
end
