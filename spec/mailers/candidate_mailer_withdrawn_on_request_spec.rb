require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  let(:candidate) { build_stubbed(:candidate) }
  let!(:application_form) { build_stubbed(:application_form, first_name: 'Fred', candidate:, application_choices:) }
  let(:provider) { build_stubbed(:provider, name: 'Arithmetic College') }
  let(:site) { build_stubbed(:site, name: 'Aquaria') }
  let(:course) { build_stubbed(:course, name: 'Mathematics', code: 'M101', provider:) }
  let(:course_option) { build_stubbed(:course_option, course:) }

  let(:other_provider) { build_stubbed(:provider, name: 'Falconholt Technical College', code: 'X100') }
  let(:other_course) { build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: other_provider) }
  let(:other_option) { build_stubbed(:course_option, course: other_course, site:) }

  let(:application_choices) { [] }

  before do
    magic_link_stubbing(candidate)
  end

  describe '.application_withdrawn_on_request_awaiting_decision_only' do
    let(:email) { mailer.application_withdrawn_on_request_awaiting_decision_only(application_choices.first) }
    let(:application_choices) { [build_stubbed(:application_choice, :awaiting_provider_decision, course_option:)] }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.application_withdrawn_on_request_awaiting_decision_only.subject', provider_name: 'Arithmetic College'),
      'heading' => 'Dear Fred',
      'withdrawn sentence' => 'At your request, Arithmetic College has withdrawn your application to study Mathematics (M101)',
      'link to support' => 'https://getintoteaching.education.gov.uk/help-and-support',
      'awaiting decision content' => 'You’re waiting for Arithmetic College to make a decision about your application to study Mathematics.',
    )

    it 'adds utm parameters when in production' do
      allow(HostingEnvironment).to receive(:environment_name).and_return('production')

      expect(email.body).to include('https://getintoteaching.education.gov.uk/help-and-support?utm_source=apply-for-teacher-training.service.gov.uk&utm_medium=referral&utm_campaign=support_footer_on_all_emails&utm_content=apply_1')
    end
  end

  describe '.application_withdrawn_on_request_offers_only' do
    let(:email) { mailer.application_withdrawn_on_request_offers_only(application_choices.first) }
    let(:application_choices) { [build_stubbed(:application_choice, :offered, course_option:, decline_by_default_at: Time.zone.local(2021, 6, 22))] }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.application_withdrawn_on_request_offers_only.subject', provider_name: 'Arithmetic College', date: Time.zone.local(2021, 6, 22).to_fs(:govuk_date)),
      'heading' => 'Dear Fred',
      'withdrawn sentence' => 'At your request, Arithmetic College has withdrawn your application to study Mathematics (M101)',
      'link to support' => 'https://getintoteaching.education.gov.uk/help-and-support',
      'offer content' => 'You’ve received an offer from Arithmetic College to study Mathematics',
    )

    it 'adds utm parameters when in production' do
      allow(HostingEnvironment).to receive(:environment_name).and_return('production')

      expect(email.body).to include('https://getintoteaching.education.gov.uk/help-and-support?utm_source=apply-for-teacher-training.service.gov.uk&utm_medium=referral&utm_campaign=support_footer_on_all_emails&utm_content=apply_1')
    end
  end
end
