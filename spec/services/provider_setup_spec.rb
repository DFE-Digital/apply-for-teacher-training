require 'rails_helper'

RSpec.describe ProviderSetup do
  describe '#next_relationship_pending' do
    let(:training_provider_user) { create(:provider_user, :with_provider, :with_manage_organisations) }
    let(:training_provider) { training_provider_user.providers.first }

    def next_relationship_pending
      ProviderSetup.new(provider_user: training_provider_user).next_relationship_pending
    end

    it 'returns a ProviderRelationshipPermissions record in need of setup' do
      create(
        :training_provider_permissions,
        training_provider: training_provider,
        ratifying_provider: create(:provider),
        setup_at: nil,
      )

      expect(next_relationship_pending).to be_a(ProviderInterface::TrainingProviderPermissions)
    end

    it 'provides all relationships pending setup for the user when called multiple times' do
      relationships = 3.times.map do
        create(
          :training_provider_permissions,
          training_provider: training_provider,
          ratifying_provider: create(:provider),
          setup_at: nil,
        )
      end
      create(:training_provider_permissions) # pending setup but unrelated

      3.times.each do |idx|
        expected_relationship = relationships[idx]
        expect(next_relationship_pending).to eq(expected_relationship)
        expected_relationship.update(setup_at: Time.current)
      end

      expect(next_relationship_pending).to be_nil
    end

    it 'returns nil if no relationships exist' do
      expect(next_relationship_pending).to be_nil
    end
  end
end
