require 'rails_helper'

RSpec.describe DsiSession do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:impersonated_provider_user).optional }
  end

  describe '#provider_user' do
    it 'returns the provider user' do
      provider_user = create(:provider_user)
      dsi_session = create(:dsi_session, user: provider_user)

      expect(dsi_session.provider_user).to eq(provider_user)
    end

    it 'returns nil if user is not provider user' do
      support_user = create(:support_user)
      dsi_session = create(:dsi_session, user: support_user)

      expect(dsi_session.provider_user).to be_nil
    end
  end

  describe '#support_user' do
    it 'returns the support user' do
      support_user = create(:support_user)
      dsi_session = create(:dsi_session, user: support_user)

      expect(dsi_session.support_user).to eq(support_user)
    end

    it 'returns nil if user is not support user' do
      provider_user = create(:provider_user)
      dsi_session = create(:dsi_session, user: provider_user)

      expect(dsi_session.support_user).to be_nil
    end
  end
end
