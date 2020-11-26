require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include TestHelpers::MailerSetupHelper

  around do |example|
    Timecop.freeze(Date.new(2020, 11, 23)) do
      example.run
    end
  end

  subject(:mailer) { described_class }

  let(:application_choice) { create(:application_choice) }
  let(:application_form) { create(:completed_application_form, application_choices: [application_choice]) }
  let(:ucas_match) do
    create(:ucas_match,
           application_form: application_form,
           action_taken: 'initial_emails_sent',
           candidate_last_contacted_at: 5.business_days.before(Time.zone.today))
  end

  describe '.ucas_match_reminder_email_duplicate_applications' do
    let(:email) { mailer.ucas_match_reminder_email_duplicate_applications(application_choice, ucas_match) }

    it 'sends an email with the correct subject' do
      expect(email.subject).to include(I18n.t!('candidate_mailer.ucas_match_reminder_email.duplicate_applications.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(email.body.encoded).to include("Dear #{application_form.full_name}")
    end

    it 'sends an email containing the course name and code in the body' do
      course_name_and_code = application_choice.course.name_and_code

      expect(email.body).to include(course_name_and_code)
    end

    it 'sends an email containing the provider name in the body' do
      provider_name = application_choice.course.provider.name

      expect(email.body).to include(provider_name)
    end

    it 'sends an email containing the date the initial email was sent' do
      expect(email.body).to include('16 November 2020')
    end

    it 'sends an email containing the date that the application needs to be withdrawn by' do

      expect(email.body).to include('30 November 2020')
    end
  end
end
