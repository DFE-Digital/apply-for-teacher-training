require 'rails_helper'

RSpec.describe ProviderSetup do
  describe '#next_agreement_pending' do
    let(:provider_user) { create(:provider_user, :with_provider) }
    let(:provider) { provider_user.providers.first }

    def next_agreement_pending
      ProviderSetup.new(provider_user: provider_user).next_agreement_pending
    end

    it 'returns an unpersisted ProviderAgreement for this provider' do
      agreement = next_agreement_pending

      expect(agreement).to be_a(ProviderAgreement)
      expect(agreement).not_to be_persisted
    end

    it 'returns nil if agreement already in place' do
      ProviderAgreement.create(
        agreement_type: :data_sharing_agreement,
        accept_agreement: true,
        provider: provider,
        provider_user: provider_user,
      )

      expect(next_agreement_pending).to be_nil
    end

    it 'provides all pending agreements the user can sign when called multiple times' do
      create(:provider_agreement, provider: provider)

      additional_providers = 2.times.map { create(:provider) }
      additional_providers.each { |provider| provider.provider_users << provider_user }
      create(:provider) # unsigned but unrelated to user

      2.times do |idx|
        agreement = next_agreement_pending
        expect(agreement.provider).to eq(additional_providers[idx])
        create(:provider_agreement, provider: additional_providers[idx])
      end

      agreement = next_agreement_pending
      expect(agreement).to be_nil
    end
  end

  describe '#next_relationship_pending' do
    let(:training_provider_user) { create(:provider_user, :with_provider, :with_manage_organisations) }
    let(:training_provider) { training_provider_user.providers.first }

    def next_relationship_pending
      ProviderSetup.new(provider_user: training_provider_user).next_relationship_pending
    end

    it 'returns a ProviderRelationshipPermissions record in need of setup' do
      create(
        :provider_relationship_permissions,
        training_provider: training_provider,
        ratifying_provider: create(:provider),
        setup_at: nil,
      )

      expect(next_relationship_pending).to be_a(ProviderRelationshipPermissions)
    end

    it 'provides all relationships pending setup for the user when called multiple times' do
      relationships = 3.times.map do
        create(
          :provider_relationship_permissions,
          training_provider: training_provider,
          ratifying_provider: create(:provider),
          setup_at: nil,
        )
      end
      create(:provider_relationship_permissions, setup_at: nil) # pending setup but unrelated

      3.times.each do |idx|
        expected_relationship = relationships[idx]
        expect(next_relationship_pending).to eq(expected_relationship)
        expected_relationship.update(setup_at: Time.zone.now)
      end

      expect(next_relationship_pending).to be_nil
    end

    it 'returns nil if no relationships exist' do
      expect(next_relationship_pending).to be_nil
    end
  end
end
