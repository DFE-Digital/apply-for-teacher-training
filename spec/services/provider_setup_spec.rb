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
    let(:provider_user) { create(:provider_user, :with_provider, :with_manage_organisations) }
    let(:provider_for_user) { provider_user.providers.first }
    let(:other_provider) { create(:provider) }
    let!(:course) { create(:course, :open_on_apply, accredited_provider: other_provider, provider: provider_for_user) }

    let(:provider_setup) { described_class.new(provider_user: provider_user) }

    context 'when there are no relationships' do
      it 'returns nil' do
        expect(provider_setup.next_relationship_pending).to be_nil
      end
    end

    context 'when there is a permission that has not been set up' do
      let!(:permission_to_set_up) do
        create(
          :provider_relationship_permissions,
          training_provider: provider_for_user,
          ratifying_provider: other_provider,
          setup_at: nil,
        )
      end

      it 'returns a ProviderRelationshipPermissions' do
        expect(provider_setup.next_relationship_pending).to be_a(ProviderRelationshipPermissions)
      end

      context 'when there is another relationship to set up' do
        let(:other_ratifying_provider) { create(:provider) }
        let!(:other_course) { create(:course, :open_on_apply, accredited_provider: other_ratifying_provider, provider: provider_for_user) }
        let!(:other_permission_to_set_up) do
          create(
            :provider_relationship_permissions,
            training_provider: provider_for_user,
            ratifying_provider: other_ratifying_provider,
            setup_at: nil,
          )
        end
        let!(:unrelated_permission) { create(:provider_relationship_permissions, setup_at: nil) }

        it 'provides all relationships pending setup for the user when called multiple times' do
          expect(provider_setup.next_relationship_pending).to eq(permission_to_set_up)
          permission_to_set_up.update(setup_at: Time.zone.now)

          expect(provider_setup.next_relationship_pending).to eq(other_permission_to_set_up)
          other_permission_to_set_up.update(setup_at: Time.zone.now)

          expect(provider_setup.next_relationship_pending).to be_nil
        end
      end

      context 'when the provider has no courses open on apply' do
        let!(:course) { create(:course, accredited_provider: other_provider, provider: provider_for_user, open_on_apply: false) }

        it 'returns nil' do
          expect(provider_setup.next_relationship_pending).to eq(nil)
        end
      end
    end

    context 'when all permissions are set up already' do
      let!(:permission_to_set_up) do
        permission = create(
          :provider_relationship_permissions,
          training_provider: provider_for_user,
          ratifying_provider: other_provider,
          training_provider_can_view_safeguarding_information: false,
          ratifying_provider_can_view_safeguarding_information: false,
          setup_at: nil,
        )
        permission.setup_at = 1.day.ago
        permission.save(validate: false)
        permission
      end

      it 'returns the first invalid manageable permission' do
        expect(provider_setup.next_relationship_pending).to eq(permission_to_set_up)
      end
    end

    context 'when the provider user is part of the ratifying provider' do
      let!(:course) { create(:course, :open_on_apply, accredited_provider: provider_for_user, provider: other_provider) }
      let!(:permission_to_set_up) do
        create(
          :provider_relationship_permissions,
          training_provider: other_provider,
          ratifying_provider: provider_for_user,
          setup_at: nil,
        )
      end

      it 'returns the relationship for which the user is the ratifier' do
        expect(provider_setup.next_relationship_pending).to eq(permission_to_set_up)
      end
    end
  end
end
