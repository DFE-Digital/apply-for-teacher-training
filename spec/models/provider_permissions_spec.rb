require 'rails_helper'

RSpec.describe ProviderPermissions do
  describe '.possible_permissions' do
    let(:current_provider_user) { create(:provider_user, providers: providers) }
    let(:provider_user) { create(:provider_user, providers: providers << non_visible_provider) }
    let(:non_visible_provider) { create(:provider, name: 'ZZZ') }
    let(:providers) do
      [
        create(:provider, name: 'ABC'),
        create(:provider, name: 'AAA'),
        create(:provider, name: 'ABB'),
      ]
    end

    before { current_provider_user.provider_permissions.update_all(manage_users: true) }

    it 'returns an ordered collection of provider permissions the current user can assign to other users' do
      expected_provider_names = described_class.possible_permissions(
        current_provider_user: current_provider_user,
        provider_user: provider_user,
      ).map { |p| p.provider.name }

      expect(expected_provider_names).to eq(%w[AAA ABB ABC])
    end
  end
end
