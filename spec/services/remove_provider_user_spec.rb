require 'rails_helper'

RSpec.describe RemoveProviderUser do
  let(:provider) { create(:provider) }
  let(:another_provider) { create(:provider) }
  let(:non_visible_provider) { create(:provider) }
  let(:current_provider_user) { create(:provider_user, providers: [provider, another_provider]) }
  let!(:user_to_remove) { create(:provider_user, providers: [provider, another_provider, non_visible_provider]) }

  before { current_provider_user.provider_permissions.update_all(manage_users: true) }

  subject(:service) do
    described_class.new(current_provider_user: current_provider_user, user_to_remove: user_to_remove)
  end

  describe 'call!' do
    it 'dissociates providers common to the managing and managed users' do
      expect { service.call! }.to change(ProviderPermissions, :count).by(-2)

      expect(user_to_remove.reload.providers).to eq([non_visible_provider])
    end
  end
end
