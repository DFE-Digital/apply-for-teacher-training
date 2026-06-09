require 'rails_helper'

RSpec.describe ProviderMailer do
  include TestHelpers::MailerSetupHelper

  describe '.respond_to_applications_before_reject_by_default_date' do
    let(:email) { described_class.respond_to_applications_before_reject_by_default_date(provider_user) }
    let(:provider) { create(:provider, name: 'Hogwarts University') }
    let(:permissions_updated_by_user) { create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { create(:provider_user, first_name: 'Joe', last_name: 'Bloggs', providers: [provider]) }
    let(:timetable) { current_timetable }
    let(:reject_by_default_date) { I18n.l(timetable.reject_by_default_at.to_date, format: :no_year) }
    let(:decline_by_default_date) { I18n.l(timetable.decline_by_default_at.to_date, format: :no_year) }
    let(:winter_reject_by_default_date) { I18n.l(timetable.winter_reject_by_default_at.to_date, format: :no_year) }

    it 'renders the content' do
      expect(email.subject).to eq("Offer places to candidates by #{reject_by_default_date} - manage teacher training applications")
      expect(email.body).to include('Dear Joe Bloggs')
      expect(email.body).to include(
        "The deadline for offering teacher training places for courses starting in September #{timetable.recruitment_cycle_year} is #{reject_by_default_date}.",
      )
      expect(email.body).to include('This includes candidates you are interviewing.')
      expect(email.body).to include(
        "If you do not make an offer by #{reject_by_default_date}, any applications for courses starting by the end of September marked as ‘received’ or ‘interviewing’ will be automatically rejected.",
      )
      expect(email.body).to include('This means you may miss out on high quality candidates.')
      expect(email.body).to include(
        "If you offer a candidate a place on a course starting by the end of September, they will have until #{decline_by_default_date} to accept it.",
      )
      expect(email.body).to include(
        "Applications for January #{timetable.recruitment_cycle_year + 1} courses will be automatically rejected after #{winter_reject_by_default_date} if you have not made an offer.",
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
