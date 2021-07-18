require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionAsProviderUserPresenter do
  let(:provider_relationship_permission) do
    build_stubbed(
      :provider_relationship_permissions,
      training_provider_can_make_decisions: true,
      training_provider_can_view_safeguarding_information: false,
      training_provider_can_view_diversity_information: false,
      ratifying_provider_can_make_decisions: true,
      ratifying_provider_can_view_safeguarding_information: true,
      ratifying_provider_can_view_diversity_information: true,
    )
  end
  let(:training_provider) { provider_relationship_permission.training_provider }
  let(:ratifying_provider) { provider_relationship_permission.ratifying_provider }

  let(:presenter) { described_class.new(provider_relationship_permission, provider_user) }

  describe '#provider_relationship_description_for' do
    context 'when the provider user is part of the training provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider]) }

      it 'returns the training provider name first' do
        expected_string = "#{training_provider.name} and #{ratifying_provider.name}"
        expect(presenter.provider_relationship_description).to eq(expected_string)
      end
    end

    context 'when the provider user is part of the ratifying provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [ratifying_provider]) }

      it 'returns the ratifying provider name first' do
        expected_string = "#{ratifying_provider.name} and #{training_provider.name}"
        expect(presenter.provider_relationship_description).to eq(expected_string)
      end
    end

    context 'when the provider user is part of both of the providers' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider, ratifying_provider]) }

      it 'returns the training provider name first' do
        expected_string = "#{training_provider.name} and #{ratifying_provider.name}"
        expect(presenter.provider_relationship_description).to eq(expected_string)
      end
    end
  end

  describe '#checkbox_details_for_providers' do
    let(:permission_name) { 'make_decisions' }

    context 'when the provider user is part of the training provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider]) }

      it 'returns the training provider relationship permission `field_name`' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:field_name]).to eq('training_provider_can_make_decisions')
      end

      it 'returns the training provider `label`' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:label]).to eq(training_provider.name)
      end

      it 'returns the training provider checkbox name' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:name]).to eq('provider_relationship_permissions[training_provider_can_make_decisions][]')
      end

      it 'returns the input checkbox value' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:checked]).to eq(provider_relationship_permission.training_provider_can_make_decisions)
      end
    end

    context 'when the provider user is part of the ratifying provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [ratifying_provider]) }

      it 'returns the ratifying provider relationship permission `field_name`' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:field_name]).to eq('ratifying_provider_can_make_decisions')
      end

      it 'returns the ratifying provider `label`' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:label]).to eq(ratifying_provider.name)
      end

      it 'returns the ratifying provider checkbox name' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:name]).to eq('provider_relationship_permissions[ratifying_provider_can_make_decisions][]')
      end

      it 'returns the input checkbox checked value' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:checked]).to eq(provider_relationship_permission.ratifying_provider_can_make_decisions)
      end
    end

    context 'when the provider user is part of both of the providers' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [ratifying_provider, training_provider]) }

      it 'returns the training provider relationship permission `field_name`' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:field_name]).to eq('training_provider_can_make_decisions')
      end

      it 'returns the training provider `label`' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:label]).to eq(training_provider.name)
      end

      it 'returns the training provider checkbox name' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:name]).to eq('provider_relationship_permissions[training_provider_can_make_decisions][]')
      end

      it 'returns the input checkbox checked value' do
        expect(presenter.checkbox_details_for_providers(permission_name).first[:checked]).to eq(provider_relationship_permission.training_provider_can_make_decisions)
      end
    end
  end

  describe '#providers_with_permission' do
    context 'when the provider user is part of the training provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider]) }

      it 'returns the names providers that have the specified permission with the training provider first' do
        expect(presenter.providers_with_permission(:make_decisions)).to eq([training_provider.name, ratifying_provider.name])
        expect(presenter.providers_with_permission(:view_safeguarding_information)).to contain_exactly(ratifying_provider.name)
        expect(presenter.providers_with_permission(:view_diversity_information)).to contain_exactly(ratifying_provider.name)
      end
    end

    context 'when the provider user is part of the ratifying provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [ratifying_provider]) }

      it 'returns the names providers that have the specified permission with the ratifying provider firs' do
        expect(presenter.providers_with_permission(:make_decisions)).to eq([ratifying_provider.name, training_provider.name])
      end
    end

    context 'when the provider user is part of both of the providers' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider, ratifying_provider]) }

      it 'returns the names providers that have the specified permission with the ratifying provider firs' do
        expect(presenter.providers_with_permission(:make_decisions)).to eq([training_provider.name, ratifying_provider.name])
      end
    end
  end
end
