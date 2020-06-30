require 'rails_helper'

RSpec.describe ProviderRelationshipPermissionsPair do
  describe '.pairs_from_collection' do
    let(:tpp1) { build_stubbed(:training_provider_permissions, ratifying_provider_id: 9, training_provider_id: 2) }
    let(:rpp1) { build_stubbed(:ratifying_provider_permissions, ratifying_provider_id: 9, training_provider_id: 2) }
    let(:tpp2) { build_stubbed(:training_provider_permissions, ratifying_provider_id: 9, training_provider_id: 1) }
    let(:rpp2) { build_stubbed(:ratifying_provider_permissions, ratifying_provider_id: 9, training_provider_id: 1) }

    let(:collection) { [tpp2, rpp1, tpp1, rpp2] }

    it 'groups a collection of ProviderRelationshipPermissions into relationship pairings' do
      pairings = described_class.pairs_from_collection(collection)

      expect(pairings.first.training_provider_permissions).to eq(tpp2)
      expect(pairings.first.ratifying_provider_permissions).to eq(rpp2)

      expect(pairings.last.training_provider_permissions).to eq(tpp1)
      expect(pairings.last.ratifying_provider_permissions).to eq(rpp1)
    end
  end
end
