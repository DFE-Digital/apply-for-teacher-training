require 'rails_helper'

RSpec.describe ProviderAuthorisation do
  include CourseOptionHelpers

  describe 'assert! methods' do
    it 'raise errors if the corresponding permission methods return false' do
      auth_context = ProviderAuthorisation.new(actor: nil)
      allow(auth_context).to receive(:can_make_offer?).and_return(true)
      expect { auth_context.assert_can_make_offer!(application_choice: nil) }.not_to raise_error
      allow(auth_context).to receive(:can_make_offer?).and_return(false)
      expect { auth_context.assert_can_make_offer!(application_choice: nil) }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
    end
  end

  describe '#can_make_offer?' do
    context 'with provider user' do
      let(:provider_user) { create(:provider_user, :with_provider, :with_make_decisions) }
      let(:provider) { provider_user.providers.first }

      it 'is false if user does not have make_decisions permission' do
        application_choice = create(:application_choice, :awaiting_provider_decision)
        provider_user.provider_permissions.where(make_decisions: true).destroy_all
        auth_context = ProviderAuthorisation.new(actor: provider_user)
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_falsy
      end

      it 'is false if user is not associated with the provider that offers the course' do
        application_choice = create(:application_choice, :awaiting_provider_decision)
        auth_context = ProviderAuthorisation.new(actor: provider_user)
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_falsy
      end

      it 'is true if user is associated with the provider that offers the course' do
        course_option = course_option_for_provider(provider: provider)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
        auth_context = ProviderAuthorisation.new(actor: provider_user)
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_truthy
      end

      it 'is true when the user is associated with the accredited provider for this course' do
        course_option = course_option_for_accredited_provider(provider: create(:provider), accredited_provider: provider)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)

        auth_context = ProviderAuthorisation.new(actor: provider_user)

        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_truthy
      end
    end

    context 'with support user' do
      it 'is true no matter what' do
        application_choice = create(:application_choice, :awaiting_provider_decision)
        auth_context = ProviderAuthorisation.new(actor: create(:support_user))
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_truthy
      end
    end

    context 'with api key' do
      it 'is false if api key is not associated with the provider that offers the course' do
        application_choice = create(:application_choice, :awaiting_provider_decision)
        auth_context = ProviderAuthorisation.new(actor: create(:vendor_api_user))
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_falsy
      end

      it 'is true if api key is associated with the provider that offers the course' do
        vendor_api_user = create(:vendor_api_user)
        course_option = course_option_for_provider(provider: vendor_api_user.vendor_api_token.provider)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
        auth_context = ProviderAuthorisation.new(actor: vendor_api_user)
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_truthy
      end
    end
  end

  describe '#can_change_offer?' do
    let(:provider_user) { create(:provider_user, :with_provider) }
    let(:provider) { provider_user.providers.first }
    let(:course_option) { course_option_for_provider(provider: provider) }
    let(:application_choice) { create(:application_choice, :with_offer, course_option: course_option) }
    let(:other_course_option) { course_option_for_provider(provider: provider) }

    it 'is true if provider_user/provider/course/course_option all match' do
      auth_context = ProviderAuthorisation.new(actor: provider_user)
      expect(auth_context.can_change_offer?(application_choice: application_choice, course_option_id: other_course_option.id)).to be_truthy
    end

    it 'is false if user is not associated with the provider for the new course option' do
      auth_context = ProviderAuthorisation.new(actor: create(:provider_user, :with_provider))
      expect(auth_context.can_change_offer?(application_choice: application_choice, course_option_id: other_course_option.id)).to be_falsy
    end

    it 'is true if user is a support user' do
      auth_context = ProviderAuthorisation.new(actor: create(:support_user))
      unrelated_course_option = create(:course_option)
      expect(auth_context.can_change_offer?(application_choice: application_choice, course_option_id: unrelated_course_option.id)).to be_truthy
    end
  end

  describe '#can_view_safeguarding_information?' do
    let(:course) { create(:course, provider: training_provider, accredited_provider: accredited_provider) }
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }
    let(:accredited_provider) { ratifying_provider }
    let(:ratifying_permissions) do
      create(
        :accredited_body_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: training_provider,
      )
    end
    let(:training_permissions) do
      create(
        :training_provider_permissions,
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

    # rubocop:disable RSpec/NestedGroups
    context 'when a user is permitted to view safeguarding info for a training provider' do
      let(:provider_user) { create(:provider_user, providers: [training_provider]) }

      before do
        provider_user.provider_permissions
          .find_by(provider: training_provider)
          .update!(view_safeguarding_information: true)

        # These permissions are intentionally unrelated to test
        # that the correct permissions are checked.
        create(
          :training_provider_permissions,
          ratifying_provider: create(:provider),
          training_provider: training_provider,
          view_safeguarding_information: true,
        )
      end

      context 'the course is self-ratified' do
        let(:accredited_provider) { nil }

        it { is_expected.to be true }
      end

      context 'the course training provider is not permitted, the course accredited provider is permitted' do
        before { ratifying_permissions.update!(view_safeguarding_information: true) }

        it { is_expected.to be false }
      end

      context 'the course accredited provider is not permitted, the course training provider is permitted' do
        before { training_permissions.update!(view_safeguarding_information: true) }

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
          :accredited_body_permissions,
          ratifying_provider: ratifying_provider,
          training_provider: create(:provider),
          view_safeguarding_information: true,
        )
      end

      context 'the course training provider is not permitted, the course accredited provider is permitted' do
        before { ratifying_permissions.update!(view_safeguarding_information: true) }

        it { is_expected.to be true }
      end

      context 'the course accredited provider is not permitted, the course training provider is permitted' do
        before { training_permissions.update!(view_safeguarding_information: true) }

        it { is_expected.to be false }
      end
    end
    # rubocop:enable RSpec/NestedGroups

    context 'when a user is not permitted to view safeguarding info' do
      let(:provider_user) { create(:provider_user, providers: [training_provider]) }

      before do
        ratifying_permissions.update!(view_safeguarding_information: true)
        training_permissions.update!(view_safeguarding_information: true)
      end

      it { is_expected.to be false }
    end
  end
end
