require 'rails_helper'

RSpec.describe ProviderMailer do
  include TestHelpers::MailerSetupHelper

  describe '.respond_to_applications_before_winter_reject_by_default_date' do
    let(:provider_user) { create(:provider_user, first_name: 'Rocket', last_name: 'The Dog') }
    let(:email) { described_class.respond_to_applications_before_winter_reject_by_default_date(provider_user) }
    let(:timetable) { previous_timetable }
    let(:winter_reject_by_default_date) { I18n.l(timetable.winter_reject_by_default_at.to_date, format: :no_year) }

    it 'renders the content' do
      expect(email.subject).to eq("Offer places to candidates by #{winter_reject_by_default_date} - manage teacher training applications")
      expect(email.body).to include('Dear Rocket The Dog')
      expect(email.body).to include(
        "The deadline for offering teacher training places for courses starting in #{timetable.winter_reject_by_default_at.to_fs(:month_and_year)} is #{timetable.winter_reject_by_default_at.to_fs(:govuk_date)}.",
      )
      expect(email.body).to include(
        "If you do not make an offer by #{timetable.winter_reject_by_default_at.to_fs(:govuk_date)}, any applications for January marked as ‘received’ or ‘interviewing’ will be automatically rejected.",
      )
      expect(email.body).to include(
        "If you offer a candidate a January place, they will have until #{timetable.winter_decline_by_default_at.to_fs(:govuk_date)} to accept it.",
      )
      expect(email.body).to include('Sign in to your account to review your applications')
      expect(email.body).to include('Contact us')
      expect(email.body).to include(
        'Get help, report a problem or give feedback at [becomingateacher@digital.education.gov.uk](mailto:becomingateacher@digital.education.gov.uk).',
      )
      expect(email.body).to include('If you want to unsubscribe from these emails')
      expect(email.body).to include('sign in to update your notification preferences')
    end
  end
end
