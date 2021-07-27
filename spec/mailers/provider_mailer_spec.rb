require 'rails_helper'

RSpec.describe ProviderMailer, type: :mailer do
  include CourseOptionHelpers

  let(:provider) { build_stubbed(:provider, :with_signed_agreement, code: 'ABC', provider_users: [provider_user]) }
  let(:site) { build_stubbed(:site, provider: provider) }
  let(:course) { build_stubbed(:course, provider: provider, name: 'Computer Science', code: '6IND') }
  let(:course_option) { build_stubbed(:course_option, course: course, site: site) }
  let(:current_course_option) { course_option }
  let(:application_choice) do
    build_stubbed(:submitted_application_choice, course_option: course_option,
                                                 current_course_option: current_course_option,
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
    Timecop.freeze do
      example.run
    end
  end

  describe 'Send account created email' do
    let(:email) { described_class.account_created(provider_user) }

    it_behaves_like('a mail with subject and content',
                    I18n.t!('provider_mailer.account_created.subject'),
                    'provider name' => 'Dear Johny English',
                    'sign in path' => '/provider/sign-in')
  end

  describe 'Send application received email' do
    let(:email) { described_class.application_submitted(provider_user, application_choice) }

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
    let(:email) { described_class.application_rejected_by_default(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    I18n.t!('provider_mailer.application_rejected_by_default.subject',
                            candidate_name: 'Harry Potter', support_reference: '123A'),
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'reject by default days' => 'within 123 working days',
                    'submission date' => 5.days.ago.to_s(:govuk_date))
  end

  describe 'Send provider decision chaser email' do
    let(:email) { described_class.chase_provider_decision(provider_user, application_choice) }
    let(:application_choice) do
      build_stubbed(:submitted_application_choice, course_option: course_option,
                                                   current_course_option: current_course_option,
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
                    'submission date' => 5.days.ago.to_s(:govuk_date),
                    'reject by default at' => 20.business_days.from_now.to_s(:govuk_date),
                    'link to the application' => 'http://localhost:3000/provider/applications/')
  end

  describe '.offer_accepted' do
    let(:email) { described_class.offer_accepted(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) has accepted your offer',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter (123A) has accepted your offer',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe '.unconditional_offer_accepted' do
    let(:email) { described_class.unconditional_offer_accepted(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) has accepted your offer',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter (123A) has accepted your offer',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe '.declined_by_default' do
    let(:email) { described_class.declined_by_default(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter’s (123A) application withdrawn automatically',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter’s (123A) application withdrawn automatically',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe 'Send email when the application withdrawn' do
    let(:email) { described_class.application_withdrawn(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) withdrew their application',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter (123A) withdrew their application',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe '.declined' do
    let(:email) { described_class.declined(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) declined an offer',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')
  end

  describe '.ucas_match_initial_email_duplicate_applications' do
    let(:email) { described_class.ucas_match_initial_email_duplicate_applications(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Duplicate application identified',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'withdraw by date' => 10.business_days.from_now.to_s(:govuk_date))
  end

  describe '.ucas_match_resolved_on_ucas_email' do
    let(:email) { described_class.ucas_match_resolved_on_ucas_email(provider_user, application_choice) }

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
    let(:email) { described_class.ucas_match_resolved_on_apply_email(provider_user, application_choice) }

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
    let(:email) { described_class.courses_open_on_apply(provider_user) }

    it_behaves_like('a mail with subject and content',
                    I18n.t!('provider_mailer.courses_open_on_apply.subject'),
                    'recruitment_cycle_year' => RecruitmentCycle.current_year)
  end

  describe 'organisation_permissions_set_up' do
    let(:training_provider) { build_stubbed(:provider, name: 'University of Purley') }
    let(:ratifying_provider) { build_stubbed(:provider, name: 'University of Croydon') }
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English', providers: [training_provider]) }
    let(:permissions) do
      build_stubbed(
        :provider_relationship_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: training_provider,
        ratifying_provider_can_view_safeguarding_information: true,
        ratifying_provider_can_view_diversity_information: true,
      )
    end
    let(:email) { ProviderMailer.organisation_permissions_set_up(provider_user, permissions) }

    it_behaves_like(
      'a mail with subject and content',
      'University of Croydon has set up organisation permissions for teacher training courses you work on with them',
      'salutation' => 'Dear Johny English',
      'heading' => 'University of Croydon has set up organisation permissions for teacher training courses you work on with them',
      'make offers' => /Make offers and reject applications:\s+- University of Purley/,
      'view safeguarding' => /View criminal convictions and professional misconduct:\s+- University of Purley\s+- University of Croydon/,
      'view diversity' => /View criminal convictions and professional misconduct:\s+- University of Purley\s+- University of Croydon/,
    )
  end

  describe 'organisation_permissions_updated' do
    let(:training_provider) { build_stubbed(:provider, name: 'University of Purley') }
    let(:ratifying_provider) { build_stubbed(:provider, name: 'University of Croydon') }
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English', providers: [training_provider]) }
    let(:permissions) do
      build_stubbed(
        :provider_relationship_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: training_provider,
        ratifying_provider_can_view_safeguarding_information: true,
        ratifying_provider_can_view_diversity_information: true,
      )
    end
    let(:email) { ProviderMailer.organisation_permissions_updated(provider_user, permissions) }

    it_behaves_like(
      'a mail with subject and content',
      'University of Croydon has changed organisation permissions for teacher training courses you work on with them',
      'salutation' => 'Dear Johny English',
      'heading' => 'University of Croydon has changed organisation permissions for teacher training courses you work on with them',
      'make offers' => /Make offers and reject applications:\s+- University of Purley/,
      'view safeguarding' => /View criminal convictions and professional misconduct:\s+- University of Purley\s+- University of Croydon/,
      'view diversity' => /View criminal convictions and professional misconduct:\s+- University of Purley\s+- University of Croydon/,
    )
  end
end
