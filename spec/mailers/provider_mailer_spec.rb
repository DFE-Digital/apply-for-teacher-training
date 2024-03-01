require 'rails_helper'

RSpec.describe ProviderMailer do
  include CourseOptionHelpers
  let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
  let!(:application_form) do
    build_stubbed(:completed_application_form, first_name: 'Harry',
                                               last_name: 'Potter',
                                               support_reference: '123A',
                                               application_choices: [application_choice],
                                               submitted_at: 5.days.ago)
  end
  let(:application_choice) do
    build_stubbed(:application_choice, :awaiting_provider_decision, course_option:,
                                                                    current_course_option:,
                                                                    reject_by_default_at: 40.days.from_now,
                                                                    reject_by_default_days: 123)
  end
  let(:current_course_option) { course_option }
  let(:course_option) { build_stubbed(:course_option, course:, site:) }
  let(:course) { build_stubbed(:course, provider:, name: 'Computer Science', code: '6IND') }
  let(:site) { build_stubbed(:site, provider:) }
  let(:provider) { build_stubbed(:provider, code: 'ABC', user: provider_user) }

  it_behaves_like 'mailer previews', ProviderMailerPreview

  describe 'Send application submitted email' do
    let(:email) { described_class.application_submitted(provider_user, application_choice) }

    context 'when a candidate submits an application' do
      it_behaves_like('a mail with subject and content',
                      'Harry Potter submitted an application for Computer Science - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'candidate name' => 'Harry Potter',
                      'course name and code' => 'Computer Science (6IND)',
                      'link to application' => /http:\/\/localhost:3000\/provider\/applications\/\d+/,
                      'notification settings' => 'You can change your email notification settings',
                      'footer' => 'Get help, report a problem or give feedback')
    end

    context 'eligible for international relocation payment' do
      before do
        allow(IsEligibleForInternationalRelocationPayment)
          .to receive(:new)
          .and_return(instance_double(IsEligibleForInternationalRelocationPayment, call: true))
      end

      it_behaves_like('a mail with subject and content',
                      'Harry Potter submitted an application for Computer Science - manage teacher training applications',
                      'international relocation' => 'help with the financial costs of moving')
    end
  end

  describe 'Send application submitted with safeguarding issues email' do
    let(:email) { described_class.application_submitted_with_safeguarding_issues(provider_user, application_choice) }

    context 'when a candidate submits an application' do
      it_behaves_like('a mail with subject and content',
                      'Safeguarding issues - Harry Potter submitted an application for Computer Science - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'candidate name' => 'Harry Potter',
                      'course name and code' => 'Computer Science (6IND)',
                      'safeguarding warning' => 'The application contains information about criminal convictions and professional misconduct.',
                      'link to application' => /http:\/\/localhost:3000\/provider\/applications\/\d+/,
                      'notification settings' => 'You can change your email notification settings',
                      'footer' => 'Get help, report a problem or give feedback')
    end

    context 'eligible for international relocation payment' do
      before do
        allow(IsEligibleForInternationalRelocationPayment)
          .to receive(:new)
          .and_return(instance_double(IsEligibleForInternationalRelocationPayment, call: true))
      end

      it_behaves_like('a mail with subject and content',
                      'Safeguarding issues - Harry Potter submitted an application for Computer Science - manage teacher training applications',
                      'international relocation' => 'help with the financial costs of moving')
    end
  end

  describe '.reference_received' do
    let(:provider) { create(:provider, code: 'ABC', user: provider_user) }
    let(:site) { create(:site, provider:) }
    let(:course) { create(:course, provider:, name: 'Computer Science', code: '6IND') }
    let(:course_option) { create(:course_option, course:, site:) }
    let(:current_course_option) { course_option }
    let(:application_choice) do
      create(:application_choice, :awaiting_provider_decision, course_option:,
                                                               current_course_option:,
                                                               reject_by_default_at: 40.days.from_now,
                                                               reject_by_default_days: 123)
    end
    let!(:application_form) do
      create(:completed_application_form, first_name: 'Harry',
                                          last_name: 'Potter',
                                          support_reference: '123A',
                                          application_choices: [application_choice],
                                          submitted_at: 5.days.ago,
                                          references_count: 0)
    end
    let(:provider_user) { create(:provider_user, first_name: 'Johny', last_name: 'English') }

    let(:reference) { create(:reference, :feedback_provided, application_form:, feedback_provided_at: Time.zone.now) }
    let(:email) { described_class.reference_received(provider_user:, application_choice:, reference:, course:) }

    before do
      application_form.application_references << create(:reference, :feedback_provided, application_form:, feedback_provided_at: Time.zone.now)
      advance_time
      application_form.application_references << create(:reference, :feedback_provided, application_form:, feedback_provided_at: Time.zone.now)
      advance_time
    end

    it_behaves_like('a mail with subject and content',
                    'Harry Potter’s third reference received - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science (6IND)',
                    'reference link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/references/)
  end

  describe '.offer_accepted' do
    let(:email) { described_class.offer_accepted(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter accepted your offer for Computer Science - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science',
                    'offer link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/offers/,
                    'notification settings' => 'You can change your email notification settings',
                    'footer' => 'Get help, report a problem or give feedback')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider:, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site:) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter accepted your offer for Welding - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding',
                      'offer link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/offers/,
                      'notification settings' => 'You can change your email notification settings',
                      'footer' => 'Get help, report a problem or give feedback')
    end
  end

  describe '.unconditional_offer_accepted' do
    let(:email) { described_class.unconditional_offer_accepted(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter accepted your offer for Computer Science - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science (6IND)',
                    'offer link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/offers/,
                    'notification settings' => 'You can change your email notification settings',
                    'footer' => 'Get help, report a problem or give feedback')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider:, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site:) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter accepted your offer for Welding - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)',
                      'offer link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/offers/,
                      'notification settings' => 'You can change your email notification settings',
                      'footer' => 'Get help, report a problem or give feedback')
    end
  end

  describe '.declined_by_default' do
    let(:email) { described_class.declined_by_default(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter’s offer for Computer Science was automatically declined - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'offer link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/offers/,
                    'notification settings' => 'You can change your email notification settings',
                    'footer' => 'Get help, report a problem or give feedback')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider:, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site:) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter’s offer for Welding was automatically declined - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end
  end

  describe 'Send email when the application withdrawn' do
    let(:number_of_cancelled_interviews) { 0 }
    let(:email) { described_class.application_withdrawn(provider_user, application_choice, number_of_cancelled_interviews) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter withdrew their application - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'link to application' => /http:\/\/localhost:3000\/provider\/applications\/\d+/,
                    'notification settings' => 'You can change your email notification settings',
                    'footer' => 'Get help, report a problem or give feedback')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider:, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course, site:) }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter withdrew their application - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end

    context 'when some interviews were cancelled' do
      let(:number_of_cancelled_interviews) { 2 }

      it_behaves_like('a mail with subject and content',
                      'Harry Potter withdrew their application - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'candidate name' => 'Harry Potter',
                      'course name and code' => 'Computer Science (6IND)',
                      'interviews_cancelled' => 'The upcoming interviews with them have been cancelled.')
    end
  end

  describe '.declined' do
    let(:email) { described_class.declined(provider_user, application_choice) }

    it_behaves_like('a mail with subject and content',
                    'Harry Potter declined your offer - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'offer link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/offers/,
                    'notification settings' => 'You can change your email notification settings',
                    'footer' => 'Get help, report a problem or give feedback')
  end

  describe 'organisation_permissions_set_up' do
    let(:training_provider) { build_stubbed(:provider, id: 123,  name: 'University of Purley') }
    let(:ratifying_provider) { build_stubbed(:provider, id: 345, name: 'University of Croydon') }
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English', providers: [training_provider]) }
    let(:permissions) do
      build_stubbed(
        :provider_relationship_permissions,
        ratifying_provider:,
        training_provider:,
        ratifying_provider_can_view_safeguarding_information: true,
        ratifying_provider_can_view_diversity_information: true,
      )
    end
    let(:email) { described_class.organisation_permissions_set_up(provider_user, training_provider, permissions) }

    it_behaves_like(
      'a mail with subject and content',
      'University of Croydon set up organisation permissions - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'heading' => 'University of Croydon set up organisation permissions for courses you run with them',
      'make offers' => /Make offers and reject applications:\s+- University of Purley/,
      'view safeguarding' => /View criminal convictions and professional misconduct:\s+- University of Purley\s+- University of Croydon/,
      'view diversity' => /View criminal convictions and professional misconduct:\s+- University of Purley\s+- University of Croydon/,
      'link to manage organisation permissions' => '/provider/organisation-settings/organisations/123/organisation-permissions',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'organisation_permissions_updated' do
    let(:training_provider) { build_stubbed(:provider, id: 123,  name: 'University of Purley') }
    let(:ratifying_provider) { build_stubbed(:provider, id: 345, name: 'University of Croydon') }
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English', providers: [training_provider]) }
    let(:permissions) do
      build_stubbed(
        :provider_relationship_permissions,
        ratifying_provider:,
        training_provider:,
        ratifying_provider_can_view_safeguarding_information: true,
        ratifying_provider_can_view_diversity_information: true,
      )
    end
    let(:email) { described_class.organisation_permissions_updated(provider_user, training_provider, permissions) }

    it_behaves_like(
      'a mail with subject and content',
      'University of Croydon changed organisation permissions - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'heading' => 'University of Croydon changed organisation permissions for courses you run with them',
      'make offers' => /Make offers and reject applications:\s+- University of Purley/,
      'view safeguarding' => /View criminal convictions and professional misconduct:\s+- University of Purley\s+- University of Croydon/,
      'view diversity' => /View sex, disability and ethnicity information:\s+- University of Purley\s+- University of Croydon/,
      'link to manage organisation permissions' => '/provider/organisation-settings/organisations/123/organisation-permissions',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'permissions_granted' do
    let(:provider) { create(:provider, name: 'Hogwards University') }
    let(:permissions_granted_by_user) { create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions) { %i[make_decisions view_safeguarding_information view_diversity_information] }

    let(:email) do
      described_class.permissions_granted(provider_user, provider, permissions, permissions_granted_by_user)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Jane Doe added you to Hogwards University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'Jane Doe added you to Hogwards University. You can now manage their applications.',
      'make decisions' => 'make offers and reject application',
      'view safeguarding' => 'view criminal convictions and professional misconduct',
      'view diversity' => 'view sex, disability and ethnicity information',
      'dsi info' => 'If you do not have a DfE Sign-in account, you should have received an email with instructions from dfe.signin@education.gov.uk.',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'permissions_granted_by_support' do
    let(:provider) { create(:provider, name: 'Hogwards University') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
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
      'dsi info' => 'If you do not have a DfE Sign-in account, you should have received an email with instructions from dfe.signin@education.gov.uk.',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'permissions_updated' do
    let(:provider) { create(:provider, name: 'Hogwards University') }
    let(:permissions_updated_by_user) { create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
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
      'link to applications' => 'http://localhost:3000/provider/applications',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'permissions_updated with all permissions removed' do
    let(:provider) { create(:provider, name: 'Hogwards University') }
    let(:permissions_updated_by_user) { create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
    let(:permissions) { %i[] }

    let(:email) do
      described_class.permissions_updated(provider_user, provider, permissions, permissions_updated_by_user)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Jane Doe updated your permissions for Hogwards University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'Jane Doe updated your permissions for Hogwards University.',
      'permissions' => 'You only have permission to view applications.',
      'link to applications' => 'http://localhost:3000/provider/applications',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'permissions_updated_by_support' do
    let(:provider) { create(:provider, name: 'Hogwards University') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }
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
      'link to applications' => 'http://localhost:3000/provider/applications',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'permissions_removed' do
    let(:provider) { create(:provider, name: 'Hogwards University') }
    let(:permissions_removed_by_user) { create(:provider_user, first_name: 'Jane', last_name: 'Doe') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }

    let(:email) do
      described_class.permissions_removed(provider_user, provider, permissions_removed_by_user)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Jane Doe has removed you from Hogwards University - manage teacher training applications',
      'salutation' => 'Dear Princess Fiona',
      'heading' => 'Jane Doe has removed you from Hogwards University. You can no longer manage their teacher training applications.',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'permissions_removed_by_support' do
    let(:provider) { create(:provider, name: 'Hogwards University') }
    let(:provider_user) { create(:provider_user, first_name: 'Princess', last_name: 'Fiona', providers: [provider]) }

    let(:email) do
      described_class.permissions_removed(provider_user, provider, nil)
    end

    it_behaves_like(
      'a mail with subject and content',
      "You've been removed from Hogwards University - manage teacher training applications",
      'salutation' => 'Dear Princess Fiona',
      'heading' => "You've been removed from Hogwards University. You can no longer manage their teacher training applications.",
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'apply_service_is_now_open', time: mid_cycle do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:email) { described_class.apply_service_is_now_open(provider_user) }

    it_behaves_like(
      'a mail with subject and content',
      'Candidates can now apply - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'main paragraph' => "The #{CycleTimetable.current_year} to #{CycleTimetable.next_year} recruitment cycle has started. Candidates can now apply to your courses.",
      'link to applications' => 'http://localhost:3000/provider/applications',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'find_service_is_now_open', time: mid_cycle do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:email) { described_class.find_service_is_now_open(provider_user) }

    it_behaves_like(
      'a mail with subject and content',
      'Candidates can now find courses - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'main paragraph' => "Candidates can now find your courses for the #{CycleTimetable.current_year} to #{CycleTimetable.next_year} recruitment cycle.",
      'Opening date paragraph' => "They’ll be able to apply on #{CycleTimetable.apply_opens.to_fs(:govuk_date)} at 9am.",
    )
  end

  describe 'set_up_organisation_permissions for single provider with one relationship' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:relationships_to_set_up) do
      { 'University of Selsdon' => ['University of Croydon'] }
    end

    let(:email) { described_class.set_up_organisation_permissions(provider_user, relationships_to_set_up) }

    it_behaves_like(
      'a mail with subject and content',
      'Set up organisation permissions - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'main paragraph' => 'Candidates can now find courses you run with:',
      'partner providers' => '- University of Croydon',
      'relationship_setup_paragraph' => 'Either you or this partner organisation',
      'when_to_setup_relationship' => 'unless your partner organisation sets them up',
      'link to applications' => 'http://localhost:3000/provider/applications',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'set_up_organisation_permissions for single provider with multiple relationships' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:relationships_to_set_up) do
      { 'University of Selsdon' => ['University of Croydon', 'University of Purley'] }
    end

    let(:email) { described_class.set_up_organisation_permissions(provider_user, relationships_to_set_up) }

    it_behaves_like(
      'a mail with subject and content',
      'Set up organisation permissions - manage teacher training applications',
      'salutation' => 'Dear Johny English',
      'main paragraph' => 'Candidates can now find courses you run with:',
      'partner providers' => /- University of Croydon\s+- University of Purley/,
      'relationship_setup_paragraph' => 'Either you or these partner organisations',
      'when_to_setup_relationship' => 'unless your partner organisations set them up',
      'link to applications' => 'http://localhost:3000/provider/applications',
      'footer' => 'Get help, report a problem or give feedback',
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
      'main paragraph' => 'Candidates can now find courses you run with the partner organisations listed below.',
      'first relationship group' => 'For University of Dundee, you need to set up permissions for courses you work on with:',
      'first group of partner providers' => /- University of Broughty Ferry\s+- University of Carnoustie/,
      'second relationship group' => 'For University of Selsdon, you need to set up permissions for courses you work on with:',
      'second group of partner providers' => /- University of Croydon\s+- University of Purley/,
      'link to applications' => 'http://localhost:3000/provider/applications',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end

  describe 'fallback-sign_inemail' do
    let(:email) { described_class.fallback_sign_in_email(provider_user, token) }
    let(:token) { :token }

    it_behaves_like('a mail with subject and content',
                    'Sign in - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'content' => 'You requested a link to sign in because DfE Sign-in is unavailable.',
                    'link to sign in' => 'http://localhost:3000/provider/sign-in-by-email?token=token',
                    'footer' => 'Get help, report a problem or give feedback')
  end

  describe 'confirm_sign_in' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:email) { described_class.confirm_sign_in(provider_user, timestamp:) }
    let(:timestamp) { Date.parse('22-02-2022').midnight }

    it_behaves_like('a mail with subject and content',
                    'Sign in from new device detected - manage teacher training applications',
                    'salutation' => 'Dear Johny',
                    'date' => '22 February 2022',
                    'time' => '12am',
                    'footer' => 'Get help, report a problem or give feedback')
  end
end
