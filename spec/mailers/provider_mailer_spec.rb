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

  describe 'Send application received email' do
    let(:email) { described_class.application_submitted(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Application received for Computer Science (6IND) - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'reject by default days' => 'after 123 working days',
                    'link to the application' => 'http://localhost:3000/provider/applications/')
  end

  describe 'Send application rejected by default email' do
    context 'when the provider user can make decisions' do
      let(:email) { described_class.application_rejected_by_default(provider_user, application_choice, can_make_decisions: true) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter’s application was automatically rejected - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'candidate name' => 'Harry Potter',
                      'course name and code' => 'Computer Science (6IND)',
                      'reject by default days' => 'within 123 working days',
                      'feedback_text' => 'You need to tell Harry Potter why their application was unsuccessful')
    end

    context 'when the provider user cannot make decisions' do
      let(:email) { described_class.application_rejected_by_default(provider_user, application_choice, can_make_decisions: false) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter’s application was automatically rejected - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'candidate name' => 'Harry Potter',
                      'course name and code' => 'Computer Science (6IND)',
                      'reject by default days' => 'within 123 working days')
    end
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
                    'Respond to Harry Potter’s (123A) application - manage teacher training applications',
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
                    'Harry Potter (123A) has accepted your offer - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter (123A) has accepted your offer - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe '.unconditional_offer_accepted' do
    let(:email) { described_class.unconditional_offer_accepted(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) has accepted your offer - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter (123A) has accepted your offer - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe '.declined_by_default' do
    let(:email) { described_class.declined_by_default(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter’s (123A) application withdrawn automatically - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter’s (123A) application withdrawn automatically - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe 'Send email when the application withdrawn' do
    let(:number_of_cancelled_interviews) { 0 }
    let(:email) { described_class.application_withdrawn(provider_user, application_choice, number_of_cancelled_interviews) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) withdrew their application - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider: provider, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site: site) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter (123A) withdrew their application - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end

    context 'when some interviews were cancelled' do
      let(:number_of_cancelled_interviews) { 2 }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter (123A) withdrew their application - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'candidate name' => 'Harry Potter',
                      'course name and code' => 'Computer Science (6IND)',
                      'interviews_cancelled' => 'The upcoming interviews with them have been cancelled.')
    end
  end

  describe '.declined' do
    let(:email) { described_class.declined(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter (123A) declined an offer - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')
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
    let(:email) { described_class.organisation_permissions_set_up(provider_user, training_provider, permissions) }

    it_behaves_like(
      'a mail with subject and content',
      'University of Croydon has set up organisation permissions for teacher training courses you work on with them - manage teacher training applications',
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
    let(:email) { described_class.organisation_permissions_updated(provider_user, training_provider, permissions) }

    it_behaves_like(
      'a mail with subject and content',
      'University of Croydon has changed organisation permissions for teacher training courses you work on with them - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'heading' => 'University of Croydon has changed organisation permissions for teacher training courses you work on with them',
      'make offers' => /Make offers and reject applications:\s+- University of Purley/,
      'view safeguarding' => /View criminal convictions and professional misconduct:\s+- University of Purley\s+- University of Croydon/,
      'view diversity' => /View sex, disability and ethnicity information:\s+- University of Purley\s+- University of Croydon/,
    )
  end

  describe 'permissions_granted' do
    let(:provider) { FactoryBot.create(:provider, name: 'Hogwards University') }
    let(:permissions_granted_by_user) { FactoryBot.create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { FactoryBot.create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions) { %i[make_decisions view_safeguarding_information view_diversity_information] }

    let(:email) do
      described_class.permissions_granted(provider_user, provider, permissions, permissions_granted_by_user)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Jane Doe has added you to Hogwards University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'Jane Doe has added you to Hogwards University. You can now manage their teacher training applications.',
      'make decisions' => 'make offers and reject application',
      'view safeguarding' => 'view criminal convictions and professional misconduct',
      'view diversity' => 'view sex, disability and ethnicity information',
    )
  end

  describe 'permissions_granted_by_support' do
    let(:provider) { FactoryBot.create(:provider, name: 'Hogwards University') }
    let(:provider_user) { FactoryBot.create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions) { %i[make_decisions view_diversity_information] }

    let(:email) do
      described_class.permissions_granted(provider_user, provider, permissions, nil)
    end

    it_behaves_like(
      'a mail with subject and content',
      "You've been added to Hogwards University - manage teacher training applications",
      'salutation' => 'Dear Princess Fiona',
      'heading' => "You've been added to Hogwards University. You can now manage their teacher training applications.",
      'make decisions' => 'make offers and reject application',
      'view diversity' => 'view sex, disability and ethnicity information',
    )
  end

  describe 'permissions_updated' do
    let(:provider) { FactoryBot.create(:provider, name: 'Hogwards University') }
    let(:permissions_updated_by_user) { FactoryBot.create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { FactoryBot.create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions) { %i[view_safeguarding_information view_diversity_information] }

    let(:email) do
      described_class.permissions_updated(provider_user, provider, permissions, permissions_updated_by_user)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Jane Doe updated your permissions for Hogwards University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'Jane Doe updated your permissions for Hogwards University.',
      'view safeguarding' => 'view criminal convictions and professional misconduct',
      'view diversity' => 'view sex, disability and ethnicity information',
    )
  end

  describe 'permissions_updated with all permissions removed' do
    let(:provider) { FactoryBot.create(:provider, name: 'Hogwards University') }
    let(:permissions_updated_by_user) { FactoryBot.create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { FactoryBot.create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions) { %i[] }

    let(:email) do
      described_class.permissions_updated(provider_user, provider, permissions, permissions_updated_by_user)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Jane Doe updated your permissions for Hogwards University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'Jane Doe updated your permissions for Hogwards University.',
      'permissiosn' => 'You only have permission to view applications.',
    )
  end

  describe 'permissions_updated_by_support' do
    let(:provider) { FactoryBot.create(:provider, name: 'Hogwards University') }
    let(:provider_user) { FactoryBot.create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions) { %i[make_decisions view_safeguarding_information] }

    let(:email) do
      described_class.permissions_updated(provider_user, provider, permissions, nil)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Your permissions have been updated for Hogwards University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'Your permissions have been updated for Hogwards University.',
      'make decisions' => 'make offers and reject application',
      'view safeguarding' => 'view criminal convictions and professional misconduct',
    )
  end

  describe 'permissions_removed' do
    let(:provider) { FactoryBot.create(:provider, name: 'Hogwards University') }
    let(:permissions_removed_by_user) { FactoryBot.create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { FactoryBot.create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }

    let(:email) do
      described_class.permissions_removed(provider_user, provider, permissions_removed_by_user)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Jane Doe has removed you from Hogwards University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'Jane Doe has removed you from Hogwards University. You can no longer manage their teacher training applications.',
    )
  end

  describe 'permissions_removed_by_support' do
    let(:provider) { FactoryBot.create(:provider, name: 'Hogwards University') }
    let(:provider_user) { FactoryBot.create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }

    let(:email) do
      described_class.permissions_removed(provider_user, provider, nil)
    end

    it_behaves_like(
      'a mail with subject and content',
      "You've been removed from Hogwards University - manage teacher training applications",
      'salutation' => 'Dear Princess Fiona',
      'heading' => "You've been removed from Hogwards University. You can no longer manage their teacher training applications.",
    )
  end

  describe 'apply_service_is_now_open' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:email) { described_class.apply_service_is_now_open(provider_user) }

    it_behaves_like(
      'a mail with subject and content',
      'Candidates can now apply for teacher training courses for 2022 to 2023 - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'main paragraph' => 'Candidates can now apply for teacher training courses on GOV.UK for the 2022 to 2023 recruitment cycle.',
    )
  end

  describe 'find_service_is_now_open' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:email) { described_class.find_service_is_now_open(provider_user) }

    it_behaves_like(
      'a mail with subject and content',
      'Candidates can now find teacher training courses for 2022 to 2023 - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'main paragraph' => 'Candidates can now find teacher training courses on GOV.UK for the 2022 to 2023 recruitment cycle.',
      'Opening date paragraph' => 'They’ll be able to apply on 12 October 2021 at 9am.',
    )
  end

  describe 'set_up_organisation_permissions' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:relationships_to_set_up) do
      { 'University of Selsdon' => ['University of Croydon', 'University of Purley'] }
    end

    let(:email) { described_class.set_up_organisation_permissions(provider_user, relationships_to_set_up) }

    it_behaves_like(
      'a mail with subject and content',
      'Set up organisation permissions - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'main paragraph' => 'Candidates can now find courses on GOV.UK that you work on with:',
      'partner providers' => "- University of Croydon\r\n- University of Purley",
    )
  end

  describe 'set_up_organisation_permissions with multiple organisations' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:relationships_to_set_up) do
      {
        'University of Dundee' => ['University of Broughty Ferry', 'University of Carnoustie'],
        'University of Selsdon' => ['University of Croydon', 'University of Purley'],
      }
    end

    let(:email) { described_class.set_up_organisation_permissions(provider_user, relationships_to_set_up) }

    it_behaves_like(
      'a mail with subject and content',
      'Set up organisation permissions - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'main paragraph' => 'Candidates can now find courses on GOV.UK that you work on with the partner organisations listed below.',
      'first relationship group' => 'For University of Dundee, you need to set up permissions for courses you work on with:',
      'first group of partner providers' => "- University of Broughty Ferry\r\n- University of Carnoustie",
      'second relationship group' => 'For University of Selsdon, you need to set up permissions for courses you work on with:',
      'second group of partner providers' => "- University of Croydon\r\n- University of Purley",
    )
  end
end
