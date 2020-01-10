require 'rails_helper'

RSpec.describe GetPendingDataSharingAgreementsForProviderUser do
  describe 'one user, one provider' do
    let(:provider) { create(:provider, :without_agreements, code: 'ABC', name: 'Example provider') }
    let(:provider_user) { create(:provider_user) }

    before { provider.provider_users << provider_user }

    it 'returns one unpersisted ProviderAgreement for this provider if no other agreements already exist' do
      pending_agreements = GetPendingDataSharingAgreementsForProviderUser.call provider_user: provider_user
      expect(pending_agreements.count).to eq(1)
      expect(pending_agreements.first.provider.id).to eq(provider.id)
      expect(pending_agreements.first).not_to be_persisted
    end

    it 'returns empty array if agreement for this provider already exists' do
      ProviderAgreement.create(accept_agreement: true, agreement_type: :data_sharing_agreement, provider: provider, provider_user: provider_user)
      pending_agreements = GetPendingDataSharingAgreementsForProviderUser.call provider_user: provider_user
      expect(pending_agreements.count).to eq(0)
    end
  end

  describe 'one user, many providers' do
    let(:provider1) { create(:provider, :without_agreements, code: 'ABC', name: 'Example provider 1') }
    let(:provider2) { create(:provider, :without_agreements, code: 'CBA', name: 'Example provider 2') }
    let(:provider_user) { create(:provider_user) }

    before do
      provider1.provider_users << provider_user
      provider2.provider_users << provider_user
    end

    it 'returns provider agreements for all associated providers if no agreements exist' do
      pending_agreements = GetPendingDataSharingAgreementsForProviderUser.call provider_user: provider_user
      expect(pending_agreements.count).to eq(2)
      expect(pending_agreements.first.provider.id).to eq(provider1.id)
      expect(pending_agreements.second.provider.id).to eq(provider2.id)
    end

    it 'returns provider agreements only for providers that need one' do
      ProviderAgreement.create(accept_agreement: true, agreement_type: :data_sharing_agreement, provider: provider2, provider_user: provider_user)
      pending_agreements = GetPendingDataSharingAgreementsForProviderUser.call provider_user: provider_user
      expect(pending_agreements.count).to eq(1)
      expect(pending_agreements.first.provider.id).to eq(provider1.id)
    end
  end
end
