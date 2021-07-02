require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionAsProviderUserPresenter do
  let(:provider_relationship_permission) { build_stubbed(:provider_relationship_permissions) }
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
    context 'when the provider user is part of the training provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider]) }

      it 'returns the training provider checkbox first' do
        expect(presenter.checkbox_details_for_providers.first[:type]).to eq('training')
      end
    end

    context 'when the provider user is part of the ratifying provider' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [ratifying_provider]) }

      it 'returns the ratifying provider checkbox first' do
        expect(presenter.checkbox_details_for_providers.first[:type]).to eq('ratifying')
      end
    end

    context 'when the provider user is part of both of the providers' do
      let(:provider_user) { build_stubbed(:provider_user, providers: [training_provider, ratifying_provider]) }

      it 'returns the training provider checkbox first' do
        expect(presenter.checkbox_details_for_providers.first[:type]).to eq('training')
      end
    end
  end
end
