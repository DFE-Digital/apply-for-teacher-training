require 'rails_helper'

RSpec.describe ProviderMailer, type: :mailer do
  include CourseOptionHelpers

  let(:provider) { build_stubbed(:provider, :with_signed_agreement, code: 'ABC', provider_users: [provider_user]) }
  let(:site) { build_stubbed(:site, provider: provider) }
  let(:offered_course_option) { nil }
  let(:course) { build_stubbed(:course, provider: provider, name: 'Computer Science', code: '6IND') }
  let(:course_option) { build_stubbed(:course_option, course: course, site: site) }
  let(:application_choice) do
    build_stubbed(:submitted_application_choice, course_option: course_option,
                                                 offered_course_option: offered_course_option,
                                                 reject_by_default_at: 40.days.from_now,
                                                 reject_by_default_days: 123)
  end
  let!(:application_form) do
    build_stubbed(:completed_application_form, first_name: 'Harry',
                                               last_name: 'Potter',
                                               support_reference: '123A',
                                               application_choices: [application_choice],
                                               submitted_at: 5.days.ago)
  end
  let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }

  around do |example|
    Timecop.freeze(Time.zone.local(2021, 1, 17)) do
      example.run
    end
  end

  describe 'Send account created email' do
    let(:email) { ProviderMailer.account_created(provider_user) }

    it_behaves_like('a mail with subject and content',
                    I18n.t!('provider_mailer.account_created.subject'),
                    'provider name' => 'Dear Johny English',
                    'sign in path' => '/provider/sign-in')
  end

  describe 'Send application received email' do
    let(:email) { ProviderMailer.application_submitted(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    I18n.t!('provider_mailer.application_submitted.subject',
                            course_name_and_code: 'Computer Science (6IND)'),
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'reject by default days' => 'after 123 working days',
                    'link to the application' => 'http://localhost:3000/provider/applications/')
  end

  describe 'Send application rejected by default email' do
    let(:email) { ProviderMailer.application_rejected_by_default(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    I18n.t!('provider_mailer.application_rejected_by_default.subject',
                            candidate_name: 'Harry Potter', support_reference: '123A'),
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'reject by default days' => 'within 123 working days',
                    'submission date' => '12 January 2021')
  end

  describe 'Send provider decision chaser email' do
    let(:email) { ProviderMailer.chase_provider_decision(provider_user, application_choice) }
    let(:application_choice) do
      build_stubbed(:submitted_application_choice, course_option: course_option,
                                                   offered_course_option: offered_course_option,
                                                   reject_by_default_at: 20.business_days.from_now,
                                                   reject_by_default_days: 123)
    end

    it_behaves_like('a mail with subject and content',
                    I18n.t!('provider_mailer.application_waiting_for_decision.subject',
                            candidate_name: 'Harry Potter', support_reference: '123A'),
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'time to respond' => 'Only 20 working days left to respond',
                    'submission date' => '12 January 2021',
                    'reject by default at' => '15 February 2021',
                    'link to the application' => 'http://localhost:3000/provider/applications/')
  end

  describe '.offer_accepted' do
    let(:email) { ProviderMailer.offer_accepted(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) has accepted your offer',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:offered_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter (123A) has accepted your offer',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe '.unconditional_offer_accepted' do
    let(:email) { ProviderMailer.unconditional_offer_accepted(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) has accepted your offer',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:offered_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter (123A) has accepted your offer',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe '.declined_by_default' do
    let(:email) { ProviderMailer.declined_by_default(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter’s (123A) application withdrawn automatically',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:offered_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter’s (123A) application withdrawn automatically',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe 'Send email when the application withdrawn' do
    let(:email) { ProviderMailer.application_withdrawn(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) withdrew their application',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:offered_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter (123A) withdrew their application',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe '.declined' do
    let(:email) { ProviderMailer.declined(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) declined an offer',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')
  end

  describe '.ucas_match_initial_email_duplicate_applications' do
    let(:email) { ProviderMailer.ucas_match_initial_email_duplicate_applications(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Duplicate application identified',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'withdraw by date' => 'February 2021')
  end

  describe '.ucas_match_resolved_on_ucas_email' do
    let(:email) { ProviderMailer.ucas_match_resolved_on_ucas_email(provider_user, application_choice) }

    before do
      allow(application_choice).to receive(:course).and_return(course)
    end

    it_behaves_like('a mail with subject and content',
                    'Duplicate application withdrawn',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')
  end

  describe '.ucas_match_resolved_on_apply_email' do
    let(:email) { ProviderMailer.ucas_match_resolved_on_apply_email(provider_user, application_choice) }

    before do
      allow(application_choice).to receive(:course).and_return(course)
    end

    it_behaves_like('a mail with subject and content',
                    'Duplicate application withdrawn',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')
  end

  describe '.courses_open_on_apply' do
    let(:email) { ProviderMailer.courses_open_on_apply(provider_user) }

    it_behaves_like('a mail with subject and content',
                    I18n.t!('provider_mailer.courses_open_on_apply.subject'),
                    'recruitment_cycle_year' => RecruitmentCycle.current_year)
  end
end
