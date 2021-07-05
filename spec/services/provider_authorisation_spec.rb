require 'rails_helper'

RSpec.describe ProviderAuthorisation do
  include CourseOptionHelpers

  describe '#assert_can_make_decisions!' do
    let(:auth_context) { ProviderAuthorisation.new(actor: nil) }

    it 'raises a ValidationException if neither a course_option or a course_option_id is provided' do
      expect { auth_context.assert_can_make_decisions!(application_choice: nil) }.to raise_error(ValidationException, 'Please provide a course_option or course_option_id')
    end

    it 'raises an error if the actor cannot make decisions' do
      allow(auth_context).to receive(:can_make_decisions?).and_return(false)

      expect { auth_context.assert_can_make_decisions!(application_choice: nil, course_option_id: build_stubbed(:course_option).id) }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
    end
  end

  describe '#can_manage_users_for_at_least_one_provider?' do
    it 'is false for users without the manage users permission' do
      provider_user = create(:provider_user)

      expect(described_class.new(actor: provider_user).can_manage_users_for_at_least_one_provider?).to be false
    end

    it 'is true for users with the manage users permission for any organisation' do
      provider_user = create(:provider_user)
      create(:provider_permissions, provider_user: provider_user, manage_users: true)

      expect(described_class.new(actor: provider_user).can_manage_users_for_at_least_one_provider?).to be true
    end
  end

  describe '#can_make_decisions?' do
    let(:training_provider_user) { create(:provider_user, :with_provider, :with_make_decisions) }
    let(:training_provider) { training_provider_user.providers.first }

    let(:ratifying_provider_user) { create(:provider_user, :with_provider, :with_make_decisions) }
    let(:ratifying_provider) { ratifying_provider_user.providers.first }

    let(:ratified_course) do
      create(
        :course,
        :open_on_apply,
        provider: training_provider,
        accredited_provider: ratifying_provider,
      )
    end
    let(:course_option_a) { create(:course_option, course: ratified_course) }

    let(:self_ratified_course) do
      create(
        :course,
        :open_on_apply,
        provider: training_provider,
      )
    end
    let(:course_option_b) { create(:course_option, course: self_ratified_course) }

    let(:application_choice) do
      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_a,
      )
    end

    let(:provider_relationship_permissions) do
      create(:provider_relationship_permissions, training_provider: training_provider, ratifying_provider: ratifying_provider)
    end

    # org-level 'make_decisions' are now required for happy path
    before do
      provider_relationship_permissions.update!(
        training_provider_can_make_decisions: true,
        ratifying_provider_can_make_decisions: true,
      )
    end

    def can_make_decisions?(actor:, choice: application_choice)
      auth_context = ProviderAuthorisation.new(actor: actor)
      auth_context.can_make_decisions?(
        application_choice: choice,
        course_option_id: choice.course_option.id,
      )
    end

    context 'actor: provider user (org-level permissions)' do
      it 'training_provider without make_decisions' do
        provider_relationship_permissions.update(training_provider_can_make_decisions: false)

        expect(can_make_decisions?(actor: ratifying_provider_user)).to be_truthy
        expect(can_make_decisions?(actor: training_provider_user)).to be_falsy
      end

      it 'ratifying_provider without make_decisions' do
        provider_relationship_permissions.update(ratifying_provider_can_make_decisions: false)

        expect(can_make_decisions?(actor: training_provider_user)).to be_truthy
        expect(can_make_decisions?(actor: ratifying_provider_user)).to be_falsy
      end

      it 'bad data: relationship record is missing' do
        provider_relationship_permissions.destroy

        expect { can_make_decisions?(actor: training_provider_user) }.to raise_error(ProviderAuthorisation::RelationshipNotPresent)
        expect { can_make_decisions?(actor: ratifying_provider_user) }.to raise_error(ProviderAuthorisation::RelationshipNotPresent)
      end

      it 'training_provider for self-ratified course can always decide' do
        for_self_ratified_course = create(
          :application_choice,
          :awaiting_provider_decision,
          course_option: course_option_b,
        )

        expect(can_make_decisions?(actor: training_provider_user, choice: for_self_ratified_course)).to be_truthy
      end
    end

    context 'actor: provider user (user-level permissions)' do
      it 'training_provider_user without make_decisions' do
        training_provider_user.provider_permissions.update_all(make_decisions: false)

        expect(can_make_decisions?(actor: training_provider_user)).to be_falsy
      end

      it 'ratifying_provider_user without make_decisions' do
        ratifying_provider_user.provider_permissions.update_all(make_decisions: false)

        expect(can_make_decisions?(actor: ratifying_provider_user)).to be_falsy
      end
    end

    context 'actor: provider user (no permissions, by association only)' do
      it 'is false if not associated with the provider that offers the course' do
        unrelated_choice = create(:application_choice, :awaiting_provider_decision)
        expect(can_make_decisions?(actor: training_provider_user, choice: unrelated_choice)).to be_falsy
      end

      it 'is true if associated with the provider that offers the course' do
        expect(can_make_decisions?(actor: training_provider_user)).to be_truthy
      end

      it 'is true if associated with the accredited provider for this course' do
        expect(can_make_decisions?(actor: ratifying_provider_user)).to be_truthy
      end
    end

    context 'actor: support user' do
      it 'is true no matter what' do
        unrelated_choice = create(:application_choice, :awaiting_provider_decision)
        expect(can_make_decisions?(actor: create(:support_user), choice: unrelated_choice)).to be_truthy
      end
    end

    context 'actor: api user (no permissions, by association only)' do
      it 'is false if api key belongs to a random provider' do
        unrelated_choice = create(:application_choice, :awaiting_provider_decision)
        expect(can_make_decisions?(actor: create(:vendor_api_user), choice: unrelated_choice)).to be_falsy
      end

      it 'is true if api key is associated with the training provider' do
        vendor_api_token = create(:vendor_api_token, provider: training_provider)
        vendor_api_user = create(:vendor_api_user, vendor_api_token: vendor_api_token)
        expect(can_make_decisions?(actor: vendor_api_user)).to be_truthy
      end

      it 'is true if api key is associated with the provider ratifying the course' do
        vendor_api_token = create(:vendor_api_token, provider: ratifying_provider)
        vendor_api_user = create(:vendor_api_user, vendor_api_token: vendor_api_token)
        expect(can_make_decisions?(actor: vendor_api_user)).to be_truthy
      end
    end

    context 'actor: api user (org-level permissions)' do
      it 'is false for training_provider without make_decisions' do
        provider_relationship_permissions.update(training_provider_can_make_decisions: false)

        vendor_api_token = create(:vendor_api_token, provider: training_provider)
        vendor_api_user = create(:vendor_api_user, vendor_api_token: vendor_api_token)
        expect(can_make_decisions?(actor: vendor_api_user)).to be_falsy
      end

      it 'is false for ratifying_provider without make_decisions' do
        provider_relationship_permissions.update(ratifying_provider_can_make_decisions: false)

        vendor_api_token = create(:vendor_api_token, provider: ratifying_provider)
        vendor_api_user = create(:vendor_api_user, vendor_api_token: vendor_api_token)
        expect(can_make_decisions?(actor: vendor_api_user)).to be_falsy
      end
    end
  end

  describe '#can_view_safeguarding_information?' do
    let(:course) { create(:course, provider: training_provider, accredited_provider: accredited_provider) }
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }
    let(:accredited_provider) { ratifying_provider }
    let(:provider_relationship_permissions) do
      create(
        :provider_relationship_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: training_provider,
      )
    end

    let(:service) { described_class.new(actor: provider_user) }

    context 'when a user is permitted to view safeguarding info for a training provider' do
      let(:provider_user) { create(:provider_user, providers: [training_provider]) }

      before do
        provider_user.provider_permissions
          .find_by(provider: training_provider)
          .update!(view_safeguarding_information: true)

        # These permissions are intentionally unrelated to test
        # that the correct permissions are checked.
        create(
          :provider_relationship_permissions,
          ratifying_provider: create(:provider),
          training_provider: training_provider,
        )
      end

      context 'the course is self-ratified' do
        let(:accredited_provider) { nil }

        it 'the user can view safeguarding information' do
          expect(service.can_view_safeguarding_information?(course: course)).to be true
        end
      end

      context 'the course training provider is not permitted, the course accredited provider is permitted' do
        before do
          provider_relationship_permissions.update!(
            ratifying_provider_can_view_safeguarding_information: true,
            training_provider_can_view_safeguarding_information: false,
          )
        end

        it 'the user cannot view safeguarding information' do
          expect(service.can_view_safeguarding_information?(course: course)).to be false
          expect(service.errors).to eq([:requires_training_provider_permission])
        end
      end

      context 'the course accredited provider is not permitted, the course training provider is permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_safeguarding_information: true) }

        it 'the user can view safeguarding information' do
          expect(service.can_view_safeguarding_information?(course: course)).to be true
        end
      end
    end

    context 'when a user is permitted to view safeguarding info for the accredited provider' do
      let(:provider_user) { create(:provider_user, providers: [ratifying_provider]) }

      before do
        provider_user.provider_permissions
          .find_by(provider: ratifying_provider)
          .update!(view_safeguarding_information: true)

        # These permissions are intentionally unrelated to test
        # that the correct permissions are checked.
        create(
          :provider_relationship_permissions,
          ratifying_provider: ratifying_provider,
          training_provider: create(:provider),
          ratifying_provider_can_view_safeguarding_information: true,
        )
      end

      context 'the course training provider is not permitted, the course accredited provider is permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_safeguarding_information: false, ratifying_provider_can_view_safeguarding_information: true) }

        it 'the user can view safeguarding information' do
          expect(service.can_view_safeguarding_information?(course: course)).to be true
        end
      end

      context 'the course accredited provider is not permitted, the course training provider is permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_safeguarding_information: true, ratifying_provider_can_view_safeguarding_information: false) }

        it 'the user cannot view safeguarding information' do
          expect(service.can_view_safeguarding_information?(course: course)).to be false
          expect(service.errors).to eq([:requires_ratifying_provider_permission])
        end
      end
    end

    context 'when a user belongs to both providers' do
      let(:provider_user) { create(:provider_user, providers: [training_provider, ratifying_provider]) }

      before do
        provider_user.provider_permissions.update_all(view_safeguarding_information: true)
      end

      context 'the course training provider is not permitted, the course accredited provider is permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_safeguarding_information: false, ratifying_provider_can_view_safeguarding_information: true) }

        it 'the user can view safeguarding information' do
          expect(service.can_view_safeguarding_information?(course: course)).to be true
        end
      end

      context 'the course accredited provider is not permitted, the course training provider is permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_safeguarding_information: true, ratifying_provider_can_view_safeguarding_information: false) }

        it 'the user can view safeguarding information' do
          expect(service.can_view_safeguarding_information?(course: course)).to be true
        end
      end

      context 'neither provider is permitted' do
        before { provider_relationship_permissions.update_columns(training_provider_can_view_safeguarding_information: false, ratifying_provider_can_view_safeguarding_information: false) }

        it 'the user cannot view safeguarding information' do
          expect(service.can_view_safeguarding_information?(course: course)).to be false
          expect(service.errors).to eq(%i[requires_training_or_ratifying_provider_permission])
        end
      end

      context 'both providers are permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_safeguarding_information: true, ratifying_provider_can_view_safeguarding_information: true) }

        it 'the user can view safeguarding information' do
          expect(service.can_view_safeguarding_information?(course: course)).to be true
        end
      end
    end

    context 'when a user is not permitted to view safeguarding info' do
      let(:provider_user) { create(:provider_user, providers: [training_provider]) }

      before do
        provider_relationship_permissions.update!(training_provider_can_make_decisions: true, ratifying_provider_can_make_decisions: true)
      end

      it 'the user cannot view safeguarding information' do
        expect(service.can_view_safeguarding_information?(course: course)).to be false
        expect(service.errors).to eq([:requires_provider_user_permission])
      end
    end
  end

  describe '#can_view_diversity_information?' do
    let(:course) { create(:course, provider: training_provider, accredited_provider: accredited_provider) }
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }
    let(:accredited_provider) { ratifying_provider }
    let(:provider_relationship_permissions) do
      create(
        :provider_relationship_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: training_provider,
      )
    end

    subject(:can_view_diversity_information) do
      described_class.new(actor: provider_user)
        .can_view_diversity_information?(course: course)
    end

    context 'when a user is permitted to view diversity info for a training provider' do
      let(:provider_user) { create(:provider_user, providers: [training_provider]) }

      before do
        provider_user.provider_permissions
          .find_by(provider: training_provider)
          .update!(view_diversity_information: true)

        # These permissions are intentionally unrelated to test
        # that the correct permissions are checked.
        create(
          :provider_relationship_permissions,
          ratifying_provider: create(:provider),
          training_provider: training_provider,
        )
      end

      context 'the course is self-ratified' do
        let(:accredited_provider) { nil }

        it { is_expected.to be true }
      end

      context 'the course training provider is not permitted, the course accredited provider is permitted' do
        before do
          provider_relationship_permissions.update!(
            ratifying_provider_can_view_diversity_information: true,
            training_provider_can_view_diversity_information: false,
          )
        end

        it { is_expected.to be false }
      end

      context 'the course accredited provider is not permitted, the course training provider is permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_diversity_information: true) }

        it { is_expected.to be true }
      end
    end

    context 'when a user is permitted to view diversity info for the accredited provider' do
      let(:provider_user) { create(:provider_user, providers: [ratifying_provider]) }

      before do
        provider_user.provider_permissions
          .find_by(provider: ratifying_provider)
          .update!(view_diversity_information: true)

        # These permissions are intentionally unrelated to test
        # that the correct permissions are checked.
        create(
          :provider_relationship_permissions,
          ratifying_provider: ratifying_provider,
          training_provider: create(:provider),
          ratifying_provider_can_view_diversity_information: true,
        )
      end

      context 'the course training provider is not permitted, the course accredited provider is permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_diversity_information: false, ratifying_provider_can_view_diversity_information: true) }

        it { is_expected.to be true }
      end

      context 'the course accredited provider is not permitted, the course training provider is permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_diversity_information: true, ratifying_provider_can_view_diversity_information: false) }

        it { is_expected.to be false }
      end
    end

    context 'when a user is not permitted to view diversity info' do
      let(:provider_user) { create(:provider_user, providers: [training_provider]) }

      before do
        provider_relationship_permissions.update!(training_provider_can_make_decisions: true, ratifying_provider_can_make_decisions: true)
      end

      it { is_expected.to be false }
    end
  end

  describe '#can_set_up_interviews?' do
    context 'for a support user' do
      let(:support_user) { create(:support_user) }

      subject(:auth_context) { ProviderAuthorisation.new(actor: support_user) }

      it 'is true' do
        expect(auth_context.can_set_up_interviews?(provider: create(:provider))).to be true
      end
    end

    context 'for a provider user with permission to set up interviews' do
      let(:provider_user) { create(:provider_user, :with_provider) }

      subject(:auth_context) { ProviderAuthorisation.new(actor: provider_user) }

      it 'is true' do
        provider = provider_user.providers.first
        provider_user.provider_permissions.find_by(provider: provider).update(set_up_interviews: true)

        expect(auth_context.can_set_up_interviews?(provider: provider)).to be true
      end
    end

    context 'for a provider user without permission to set up interviews' do
      let(:provider_user) { create(:provider_user, :with_provider) }

      subject(:auth_context) { ProviderAuthorisation.new(actor: provider_user) }

      it 'is false' do
        provider = provider_user.providers.first
        provider_user.provider_permissions.find_by(provider: provider).update(set_up_interviews: true)

        expect(auth_context.can_manage_organisation?(provider: create(:provider))).to be false
      end
    end
  end

  describe 'can_manage_organisation?' do
    context 'for a support user' do
      let(:support_user) { create(:support_user) }

      subject(:auth_context) { ProviderAuthorisation.new(actor: support_user) }

      it 'is true' do
        expect(auth_context.can_manage_organisation?(provider: create(:provider))).to be true
      end
    end

    context 'for a provider user with permission to manage an organisation' do
      let(:provider_user) { create(:provider_user, :with_provider) }

      subject(:auth_context) { ProviderAuthorisation.new(actor: provider_user) }

      it 'is true' do
        provider = provider_user.providers.first
        provider_user.provider_permissions.find_by(provider: provider).update(manage_organisations: true)

        expect(auth_context.can_manage_organisation?(provider: provider)).to be true
      end
    end

    context 'for a provider user without permission to manage an organisation' do
      let(:provider_user) { create(:provider_user, :with_provider) }

      subject(:auth_context) { ProviderAuthorisation.new(actor: provider_user) }

      it 'is false' do
        provider = provider_user.providers.first
        provider_user.provider_permissions.find_by(provider: provider).update(manage_organisations: true)

        expect(auth_context.can_manage_organisation?(provider: create(:provider))).to be false
      end
    end
  end

  describe '#providers_that_actor_can_manage_organisations_for' do
    it 'returns only providers the given user can manage permissions for and which have relationships to manage' do
      a_provider = create(:provider)
      training_provider = create(:provider)
      ratifying_provider = create(:provider)

      provider_user = create(:provider_user, providers: [training_provider, ratifying_provider, a_provider])

      # The user will have manage_organisations for a_provider but it has
      # no relationships so it should not be returned.
      ProviderPermissions.find_by(
        provider_user: provider_user,
        provider: a_provider,
      ).update!(
        manage_organisations: true,
      )

      # there is a relationship to manage between these two providers...
      create(:provider_relationship_permissions,
             training_provider: training_provider,
             ratifying_provider: ratifying_provider)

      # ...but the user only has manage_organisations permissions for the training_provider.
      ProviderPermissions.find_by(
        provider_user: provider_user,
        provider: training_provider,
      ).update!(
        manage_organisations: true,
      )

      expect(ProviderAuthorisation.new(actor: provider_user).providers_that_actor_can_manage_organisations_for)
        .to eq([training_provider])
    end

    context 'when filtering out training provider permissions that have not been set up' do
      let(:training_provider) { create(:provider) }
      let(:ratifying_provider) { create(:provider) }

      it 'only returns providers with permissions that do not have setup_at set to nil' do
        provider_user = create(:provider_user, providers: [training_provider])

        # there is a relationship to manage between these two providers...
        create(:provider_relationship_permissions,
               training_provider: training_provider,
               ratifying_provider: ratifying_provider,
               setup_at: nil)

        # ...but the user only has manage_organisations permissions for the training_provider.
        ProviderPermissions.find_by(
          provider_user: provider_user,
          provider: training_provider,
        ).update!(
          manage_organisations: true,
        )

        expect(ProviderAuthorisation.new(actor: provider_user).providers_that_actor_can_manage_organisations_for(with_set_up_permissions: true))
          .to eq([])
      end

      it 'filters out ratifying provider relationships which are not set up' do
        provider_user = create(:provider_user, providers: [ratifying_provider])

        ProviderPermissions.find_by(
          provider_user: provider_user,
          provider: ratifying_provider,
        ).update!(
          manage_organisations: true,
        )

        create(:provider_relationship_permissions,
               training_provider: training_provider,
               ratifying_provider: ratifying_provider,
               setup_at: nil)

        expect(ProviderAuthorisation.new(actor: provider_user).providers_that_actor_can_manage_organisations_for(with_set_up_permissions: true))
          .to eq([])
      end
    end
  end

  describe '#provider_relationships_that_actor_can_manage_organisations_for' do
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }

    let!(:provider_relationship) do
      create(
        :provider_relationship_permissions,
        training_provider: training_provider,
        ratifying_provider: ratifying_provider,
      )
    end

    it 'returns training provider relationships the user has manage orgs for' do
      provider_user = create(:provider_user, providers: [training_provider])

      ProviderPermissions.find_by(
        provider_user: provider_user,
        provider: training_provider,
      ).update!(manage_organisations: true)

      expect(ProviderAuthorisation.new(actor: provider_user).provider_relationships_that_actor_can_manage_organisations_for).to eq([provider_relationship])
    end

    it 'returns ratifying provider relationships the user has manage orgs for' do
      provider_user = create(:provider_user, providers: [ratifying_provider])

      ProviderPermissions.find_by(
        provider_user: provider_user,
        provider: ratifying_provider,
      ).update!(manage_organisations: true)

      expect(ProviderAuthorisation.new(actor: provider_user).provider_relationships_that_actor_can_manage_organisations_for).to eq([provider_relationship])
    end

    it 'does not return any relationships if user lacks manage orgs' do
      provider_user = create(:provider_user, providers: [training_provider, ratifying_provider])
      expect(ProviderAuthorisation.new(actor: provider_user).provider_relationships_that_actor_can_manage_organisations_for).to be_empty
    end
  end
end
