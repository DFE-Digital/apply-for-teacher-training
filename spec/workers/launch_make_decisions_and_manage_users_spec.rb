require 'rails_helper'

RSpec.describe LaunchMakeDecisionsAndManageUsers do
  before do
    @users = [
      create(:provider_user, :with_provider, :with_manage_users),
      create(:provider_user, :with_two_providers),
      create(:provider_user, :with_provider, :with_make_decisions, :with_manage_users),
    ]

    @users.second.provider_permissions.first.update(manage_users: true)
  end

  context '#perform' do
    before do
      ProviderPermissions.update_all(manage_users: true)
      described_class.new.perform
    end

    it 'gives all existing provider users make_decisions for all their providers' do
      expect(ProviderPermissions.count).to eq(4)
      expect(ProviderPermissions.find_each.all?(&:make_decisions)).to be_truthy
    end
  end

  context '#all_providers_have_at_least_one_user_with_manage_users?' do
    it 'returns false if some providers cannot manage their own users' do
      expect(described_class.new.all_providers_have_at_least_one_user_with_manage_users?).to be_falsy
    end

    it 'returns true if all providers have at least one user with manage_users' do
      @users.second.provider_permissions.second.update(manage_users: true)

      expect(described_class.new.all_providers_have_at_least_one_user_with_manage_users?).to be_truthy
    end
  end
end
