require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUserProvidersForm do
  describe '#save' do
    it 'prevents adding people to organisations they do not have access to' do
      provider_user = create(:provider_user)

      provider = create(:provider)
      provider_i_dont_have_access_to = create(:provider)
      current_provider_user = create(:provider_user)
      create(:provider_permissions, provider_user: current_provider_user, provider: provider, manage_users: true)

      described_class.new(
        provider_user: provider_user,
        current_provider_user: current_provider_user,
        provider_ids: [provider.id, provider_i_dont_have_access_to.id],
      ).save

      expect(provider_user.providers).to include(provider)
      expect(provider_user.providers).not_to include(provider_i_dont_have_access_to)
    end
  end
end
