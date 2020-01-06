require 'rails_helper'

RSpec.describe ProviderAgreement, type: :model do
  describe 'a valid provider_agreement' do
    subject(:provider_agreement) { create(:provider_agreement) }

    it { is_expected.to belong_to :provider }
    it { is_expected.to belong_to :provider_user }
    it { is_expected.to validate_presence_of :agreement_type }
    it { is_expected.to validate_presence_of :accept_agreement }
  end

  describe 'provider/provider_user association' do
    it 'is validated in the model' do
      provider = create(:provider, :without_agreements)
      provider_user = create(:provider_user)
      agreement = ProviderAgreement.create(agreement_type: :data_sharing_agreement, provider: provider, provider_user: provider_user, accept_agreement: true)
      expect(agreement).not_to be_valid
    end
  end

  describe ':accepted_at' do
    it 'is set automatically on :create' do
      provider = create(:provider, :without_agreements)
      provider_user = create(:provider_user)
      provider.provider_users << provider_user
      agreement = ProviderAgreement.create(agreement_type: :data_sharing_agreement, provider: provider, provider_user: provider_user, accept_agreement: true)
      expect(agreement.accepted_at).not_to be_nil
    end
  end

  describe '#data_sharing_agreements' do
    it 'returns only data_sharing_agreements' do
      create(:provider_agreement, agreement_type: :data_sharing_agreement)
      create(:provider_agreement, agreement_type: :other_type)
      expect(ProviderAgreement.count).to eq(2)
      expect(ProviderAgreement.data_sharing_agreements.count).to eq(1)
    end
  end

  describe '#for_provider' do
    it 'returns agreements scoped to a provider' do
      data_sharing_agreement = create(:provider_agreement, agreement_type: :data_sharing_agreement)
      other_provider = create(:provider, :without_agreements, code: 'ZZZ', name: 'Other')
      create(:provider_agreement, provider: other_provider)
      expect(ProviderAgreement.count).to eq(2)
      expect(ProviderAgreement.for_provider(data_sharing_agreement.provider).count).to eq(1)
    end
  end
end
