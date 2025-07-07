require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  let(:email) { described_class.eoc_first_deadline_reminder(application_form) }

  describe '.eoc_first_deadline_reminder' do
    context 'renders expected content' do
      it_behaves_like(
        'a mail with subject and content',
        'Submit your teacher training application before courses fill up',
        'heading' => 'Dear Fred',
        'realistic job preview heading' => 'Gain insights into life as a teacher',
        'realistic job preview' => 'Try the realistic job preview tool',
        'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
      )

      it_behaves_like 'an email with unsubscribe option'

      it 'renders the correct dates' do
        expect(email.body).to include("as soon as you can to get on a course starting in the #{current_timetable.academic_year_range_name} academic year.")
        expect(email.body).to include("The deadline to submit your application is 6pm UK time on #{current_timetable.apply_deadline_at.to_fs(:govuk_date)}")
      end

      it 'renders adviser sign up text if not already assigned' do
        expect(email.body).to include('You can also [get a teacher training adviser]')
      end
    end

    context 'includes utm parameters' do
      it 'adds utm parameters to GIT links within email body in production' do
        allow(HostingEnvironment).to receive(:environment_name).and_return('production')

        expect(email.body).to include('utm_source=apply-for-teacher-training.service.gov.uk')
        expect(email.body).to include('utm_medium=referral')
        expect(email.body).to include('utm_campaign=eoc_deadline_reminder')
        expect(email.body).to include('utm_content=apply_1')
      end
    end
  end

  describe 'tailored teacher training adviser text for "assigned" adviser status' do
    let(:application_form_with_adviser_eligibility) { create(:application_form_eligible_for_adviser, adviser_status: 'assigned') }

    subject(:email) { described_class.eoc_first_deadline_reminder(application_form_with_adviser_eligibility) }

    it 'refers to existing adviser' do
      expect(email.body).to have_content 'You can also contact your teacher training adviser for support with writing your application.'
    end
  end
end
