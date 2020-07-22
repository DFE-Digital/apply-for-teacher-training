require 'rails_helper'

RSpec.describe ProviderAuthorisation do
  include CourseOptionHelpers

  describe '#assert_can_make_offer!' do
    it 'raises an error if the actor cannot make offers' do
      auth_context = ProviderAuthorisation.new(actor: nil)
      allow(auth_context).to receive(:can_make_offer?).and_return(true)
      expect { auth_context.assert_can_make_offer!(application_choice: nil, course_option_id: nil) }.not_to raise_error
      allow(auth_context).to receive(:can_make_offer?).and_return(false)
      expect { auth_context.assert_can_make_offer!(application_choice: nil, course_option_id: nil) }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
    end
  end

  describe '#can_make_offer?' do
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

    def can_make_offer?(actor:, choice: application_choice)
      auth_context = ProviderAuthorisation.new(actor: actor)
      auth_context.can_make_offer?(
        application_choice: choice,
        course_option_id: choice.course_option.id,
      )
    end

    context 'actor: provider user (org-level permissions)' do
      before do
        FeatureFlag.activate(:enforce_provider_to_provider_permissions)
        FeatureFlag.activate(:providers_can_manage_users_and_permissions)
      end

      it 'training_provider without make_decisions' do
        provider_relationship_permissions.update(training_provider_can_make_decisions: false)

        expect(can_make_offer?(actor: ratifying_provider_user)).to be_truthy
        expect(can_make_offer?(actor: training_provider_user)).to be_falsy
      end

      it 'ratifying_provider without make_decisions' do
        provider_relationship_permissions.update(ratifying_provider_can_make_decisions: false)

        expect(can_make_offer?(actor: training_provider_user)).to be_truthy
        expect(can_make_offer?(actor: ratifying_provider_user)).to be_falsy
      end

      it 'training_provider for self-ratified course can always offer' do
        for_self_ratified_course = create(
          :application_choice,
          :awaiting_provider_decision,
          course_option: course_option_b,
        )

        expect(can_make_offer?(actor: training_provider_user, choice: for_self_ratified_course)).to be_truthy
      end
    end

    context 'actor: provider user (user-level permissions)' do
      before { FeatureFlag.activate(:providers_can_manage_users_and_permissions) }

      it 'training_provider_user without make_decisions' do
        training_provider_user.provider_permissions.update_all(make_decisions: false)

        expect(can_make_offer?(actor: training_provider_user)).to be_falsy
      end

      it 'ratifying_provider_user without make_decisions' do
        ratifying_provider_user.provider_permissions.update_all(make_decisions: false)

        expect(can_make_offer?(actor: ratifying_provider_user)).to be_falsy
      end
    end

    context 'actor: provider user (no permissions, by association only)' do
      it 'is false if not associated with the provider that offers the course' do
        unrelated_choice = create(:application_choice, :awaiting_provider_decision)
        expect(can_make_offer?(actor: training_provider_user, choice: unrelated_choice)).to be_falsy
      end

      it 'is true if associated with the provider that offers the course' do
        expect(can_make_offer?(actor: training_provider_user)).to be_truthy
      end

      it 'is true if associated with the accredited provider for this course' do
        expect(can_make_offer?(actor: ratifying_provider_user)).to be_truthy
      end
    end

    context 'actor: support user' do
      it 'is true no matter what' do
        unrelated_choice = create(:application_choice, :awaiting_provider_decision)
        expect(can_make_offer?(actor: create(:support_user), choice: unrelated_choice)).to be_truthy
      end
    end

    context 'actor: api user (no permissions, by association only)' do
      it 'is false if api key belongs to a random provider' do
        unrelated_choice = create(:application_choice, :awaiting_provider_decision)
        expect(can_make_offer?(actor: create(:vendor_api_user), choice: unrelated_choice)).to be_falsy
      end

      it 'is true if api key is associated with the training provider' do
        vendor_api_token = create(:vendor_api_token, provider: training_provider)
        vendor_api_user = create(:vendor_api_user, vendor_api_token: vendor_api_token)
        expect(can_make_offer?(actor: vendor_api_user)).to be_truthy
      end

      it 'is true if api key is associated with the provider ratifying the course' do
        vendor_api_token = create(:vendor_api_token, provider: ratifying_provider)
        vendor_api_user = create(:vendor_api_user, vendor_api_token: vendor_api_token)
        expect(can_make_offer?(actor: vendor_api_user)).to be_truthy
      end
    end

    context 'actor: api user (org-level permissions)' do
      before do
        FeatureFlag.activate(:enforce_provider_to_provider_permissions)
        FeatureFlag.activate(:providers_can_manage_users_and_permissions)
      end

      it 'is false for training_provider without make_decisions' do
        provider_relationship_permissions.update(training_provider_can_make_decisions: false)

        vendor_api_token = create(:vendor_api_token, provider: training_provider)
        vendor_api_user = create(:vendor_api_user, vendor_api_token: vendor_api_token)
        expect(can_make_offer?(actor: vendor_api_user)).to be_falsy
      end

      it 'is false for ratifying_provider without make_decisions' do
        provider_relationship_permissions.update(ratifying_provider_can_make_decisions: false)

        vendor_api_token = create(:vendor_api_token, provider: ratifying_provider)
        vendor_api_user = create(:vendor_api_user, vendor_api_token: vendor_api_token)
        expect(can_make_offer?(actor: vendor_api_user)).to be_falsy
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

    before do
      FeatureFlag.activate(:enforce_provider_to_provider_permissions)
    end

    subject(:can_view_safeguarding_information) do
      described_class.new(actor: provider_user)
        .can_view_safeguarding_information?(course: course)
    end

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

        it { is_expected.to be true }
      end

      context 'the course training provider is not permitted, the course accredited provider is permitted' do
        before do
          provider_relationship_permissions.update!(
            ratifying_provider_can_view_safeguarding_information: true,
            training_provider_can_view_safeguarding_information: false,
          )
        end

        it { is_expected.to be false }
      end

      context 'the course accredited provider is not permitted, the course training provider is permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_safeguarding_information: true) }

        it { is_expected.to be true }
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

        it { is_expected.to be true }
      end

      context 'the course accredited provider is not permitted, the course training provider is permitted' do
        before { provider_relationship_permissions.update!(training_provider_can_view_safeguarding_information: true, ratifying_provider_can_view_safeguarding_information: false) }

        it { is_expected.to be false }
      end
    end

    context 'when a user is not permitted to view safeguarding info' do
      let(:provider_user) { create(:provider_user, providers: [training_provider]) }

      before do
        provider_relationship_permissions.update!(training_provider_can_make_decisions: true, ratifying_provider_can_make_decisions: true)
      end

      it { is_expected.to be false }
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
end
