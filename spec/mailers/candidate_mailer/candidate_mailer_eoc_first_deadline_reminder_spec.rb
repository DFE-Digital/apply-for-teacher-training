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
        'cycle_details' => "as soon as you can to get on a course starting in the #{RecruitmentCycle.current_year} to #{RecruitmentCycle.next_year} academic year.",
        'details' => "The deadline to submit your application is 6pm on #{CycleTimetable.apply_deadline.to_fs(:govuk_date)}",
        'realistic job preview heading' => 'Gain insights into life as a teacher',
        'realistic job preview' => 'Try the realistic job preview tool',
        'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
      )

      it_behaves_like 'an email with unsubscribe option'
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
end