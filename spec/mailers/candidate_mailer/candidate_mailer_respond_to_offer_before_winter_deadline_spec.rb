require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  let(:email) { described_class.respond_to_offer_before_winter_deadline(application_form) }
  let(:timetable) { application_form.recruitment_cycle_timetable }
  let(:winter_deadline) { timetable.winter_decline_by_default_at.to_fs(:govuk_date_time_time_first) }
  let(:next_recruitment_cycle_year) { timetable.relative_next_year }

  describe '.respond_to_offer_before_winter_deadline' do
    it 'renders the content' do
      expect(email.subject).to eq(
        "Accept your place on a teacher training course by #{winter_deadline}",
      )
      expect(email.body).to include("Dear #{application_form.first_name}")
      expect(email.body).to include('You have been offered a place on a teacher training course.')
      expect(email.body).to include("If you want to accept this place, you must do so by #{winter_deadline}.")
      expect(email.body).to include('Sign in to your account to update your details')
      expect(email.body).to include('Your other applications')
      expect(email.body).to include(
        "Your other applications for teacher training starting in January #{next_recruitment_cycle_year} have been automatically rejected.",
      )
      expect(email.body).to include(
        'This is because the provider did not respond before their deadline. If you have any questions about this, please contact the provider.',
      )
      expect(email.body).to include('What happens next')
      expect(email.body).to include(
        "If you want to accept your offer of a place on a teacher training course, you must do so by #{winter_deadline}.",
      )
      expect(email.body).to include(
        "If you do not want to accept this offer, you can still apply to courses starting in September #{next_recruitment_cycle_year}.",
      )
      expect(email.body).to include('Sign in to your account to apply for courses')
      expect(email.body).to include(
        'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
      )
    end
  end
end
