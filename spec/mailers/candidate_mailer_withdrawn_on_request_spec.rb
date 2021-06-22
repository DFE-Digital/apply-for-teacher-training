require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  let(:candidate) { build_stubbed(:candidate) }
  let!(:application_form) { build_stubbed(:application_form, first_name: 'Fred', candidate: candidate, application_choices: application_choices) }
  let(:provider) { build_stubbed(:provider, name: 'Arithmetic College') }
  let(:site) { build_stubbed(:site, name: 'Aquaria') }
  let(:course) { build_stubbed(:course, name: 'Mathematics', code: 'M101', provider: provider) }
  let(:course_option) { build_stubbed(:course_option, course: course) }

  let(:other_provider) { build_stubbed(:provider, name: 'Falconholt Technical College', code: 'X100') }
  let(:other_course) { build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: other_provider) }
  let(:other_option) { build_stubbed(:course_option, course: other_course, site: site) }

  let(:application_choices) { [] }

  before do
    magic_link_stubbing(candidate)
  end

  describe '.application_withdrawn_on_request_all_applications_withdrawn' do
    let(:email) { mailer.application_withdrawn_on_request_all_applications_withdrawn(application_choices.first) }
    let(:application_choices) { [build_stubbed(:application_choice, :rejected, course_option: course_option)] }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.application_withdrawn_on_request_all_applications_withdrawn.subject', provider_name: 'Arithmetic College'),
      'heading' => 'Dear Fred',
      'withdrawn sentence' => 'At your request, Arithmetic College has withdrawn your application to study Mathematics (M101)',
      'link to support' => 'https://getintoteaching.education.gov.uk/#talk-to-us',
      'apply again' => 'You can apply again',
    )
  end

  describe '.application_withdrawn_on_request_awaiting_decision_only' do
    let(:email) { mailer.application_withdrawn_on_request_awaiting_decision_only(application_choices.first) }
    let(:application_choices) { [build_stubbed(:application_choice, :awaiting_provider_decision, course_option: course_option)] }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.application_withdrawn_on_request_awaiting_decision_only.subject', provider_name: 'Arithmetic College'),
      'heading' => 'Dear Fred',
      'withdrawn sentence' => 'At your request, Arithmetic College has withdrawn your application to study Mathematics (M101)',
      'link to support' => 'https://getintoteaching.education.gov.uk/#talk-to-us',
      'awaiting decision content' => 'You’re waiting for Arithmetic College to make a decision about your application to study Mathematics.',
    )
  end

  describe '.application_withdrawn_on_request_offers_only' do
    let(:email) { mailer.application_withdrawn_on_request_offers_only(application_choices.first) }
    let(:application_choices) { [build_stubbed(:application_choice, :with_offer, course_option: course_option, decline_by_default_at: Time.zone.local(2021, 6, 22))] }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.application_withdrawn_on_request_offers_only.subject', provider_name: 'Arithmetic College', date: Time.zone.local(2021, 6, 22).to_s(:govuk_date)),
      'heading' => 'Dear Fred',
      'withdrawn sentence' => 'At your request, Arithmetic College has withdrawn your application to study Mathematics (M101)',
      'link to support' => 'https://getintoteaching.education.gov.uk/#talk-to-us',
      'offer content' => 'You’ve received an offer from Arithmetic College to study Mathematics',
    )
  end

  describe '.application_withdrawn_on_request_one_offer_one_awaiting_decision' do
    let(:email) { mailer.application_withdrawn_on_request_one_offer_one_awaiting_decision(application_choices.first) }
    let(:application_choices) do
      [
        build_stubbed(:application_choice, :with_offer, course_option: course_option, decline_by_default_at: Time.zone.local(2021, 6, 22)),
        build_stubbed(:application_choice, :awaiting_provider_decision, course_option: other_option, reject_by_default_at: Time.zone.local(2021, 7, 1)),
      ]
    end

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.application_withdrawn_on_request_one_offer_one_awaiting_decision.subject', provider_name: 'Arithmetic College'),
      'heading' => 'Dear Fred',
      'withdrawn sentence' => 'At your request, Arithmetic College has withdrawn your application to study Mathematics (M101)',
      'link to support' => 'https://getintoteaching.education.gov.uk/#talk-to-us',
      'offer content' => 'You have an offer from Arithmetic College to study Mathematics.',
      'awaiting decision content' => 'Falconholt Technical College has until 1 July 2021 to make a decision about your application to study Forensic Science.',
    )
  end
end
