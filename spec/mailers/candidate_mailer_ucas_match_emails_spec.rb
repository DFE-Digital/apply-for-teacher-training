require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  describe '.ucas_match_resolved_on_ucas_email' do
    let(:ucas_match) { create(:ucas_match) }
    let(:application_form) { ucas_match.candidate.application_forms.first }
    let(:application_choice) { application_form.application_choices.first }
    let(:email) { mailer.ucas_match_resolved_on_ucas_email(application_choice) }

    it 'sends an email with the correct subject' do
      expect(email.subject).to include(I18n.t!('candidate_mailer.ucas_match.resolved_on_ucas.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(email.body.encoded).to include("Dear #{application_form.full_name}")
    end

    it 'sends an email containing the course name and code in the body' do
      course_name_and_code = application_choice.course.name_and_code

      expect(email.body).to include(course_name_and_code)
    end

    it 'sends an email containing the candidate full name in the body' do
      full_name = application_form.full_name

      expect(email.body).to include(full_name)
    end

    it 'sends an email containing the provider name in the body' do
      provider_name = application_choice.course.provider.name

      expect(email.body).to include(provider_name)
    end
  end
end
