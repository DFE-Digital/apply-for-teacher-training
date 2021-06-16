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
    let(:ratifying_provider) { create(:provider) }
    let!(:course) { create(:course, :open_on_apply, accredited_provider: ratifying_provider, provider: training_provider) }

    def next_relationship_pending
      ProviderSetup.new(provider_user: training_provider_user).next_relationship_pending
    end

    it 'returns a ProviderRelationshipPermissions record in need of setup' do
      create(
        :provider_relationship_permissions,
        training_provider: training_provider,
        ratifying_provider: ratifying_provider,
        setup_at: nil,
      )

      expect(next_relationship_pending).to be_a(ProviderRelationshipPermissions)
    end

    it 'provides all relationships pending setup for the user when called multiple times' do
      second_ratifying_provider = create(:provider)
      create(:course, :open_on_apply, accredited_provider: second_ratifying_provider, provider: training_provider)
      first_relationship = create(
        :provider_relationship_permissions,
        training_provider: training_provider,
        ratifying_provider: ratifying_provider,
        setup_at: nil,
      )
      second_relationship = create(
        :provider_relationship_permissions,
        training_provider: training_provider,
        ratifying_provider: second_ratifying_provider,
        setup_at: nil,
      )
      create(:provider_relationship_permissions, setup_at: nil) # pending setup but unrelated

      expect(next_relationship_pending).to eq(first_relationship)
      first_relationship.update(setup_at: Time.zone.now)
      expect(next_relationship_pending).to eq(second_relationship)
      second_relationship.update(setup_at: Time.zone.now)

      expect(next_relationship_pending).to be_nil
    end

    it 'provides the next invalid ProviderRelationshipPermissions record to set up' do
      relationship = create(
        :provider_relationship_permissions,
        training_provider: training_provider,
        ratifying_provider: ratifying_provider,
        training_provider_can_view_safeguarding_information: false,
        ratifying_provider_can_view_safeguarding_information: false,
        setup_at: nil,
      )
      relationship.setup_at = Time.zone.now
      relationship.save(validate: false)

      expect(next_relationship_pending).to eq(relationship)
    end

    it 'returns nil if no relationships exist' do
      expect(next_relationship_pending).to be_nil
    end

    context 'when the provider has no courses open on apply' do
      let!(:course) { create(:course, accredited_provider: ratifying_provider, provider: training_provider, open_on_apply: false) }

      it 'returns nil' do
        create(
          :provider_relationship_permissions,
          training_provider: training_provider,
          ratifying_provider: ratifying_provider,
          training_provider_can_view_safeguarding_information: false,
          ratifying_provider_can_view_safeguarding_information: false,
          setup_at: nil,
        )
        expect(next_relationship_pending).to eq(nil)
      end
    end
  end
end
