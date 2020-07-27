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

  describe '#update_provider_user_permissions!' do
    before do
      ProviderPermissions.update_all(manage_users: true)
      described_class.new.update_provider_user_permissions!
    end

    it 'gives all existing provider users make_decisions for all their providers' do
      expect(ProviderPermissions.count).to eq(4)
      expect(ProviderPermissions.find_each.all?(&:make_decisions)).to be_truthy
    end
  end

  describe '#give_manage_users_to_the_user_who_has_signed_the_dsa!' do
    it 'does what it says on the tin' do
      agreement = create(:provider_agreement)
      described_class.new.give_manage_users_to_the_user_who_has_signed_the_dsa!
      permission = agreement.provider_user.provider_permissions.first
      expect(permission.manage_users).to be_truthy
    end
  end

  describe '#all_providers_have_at_least_one_user_with_manage_users?' do
    it 'returns false if some providers cannot manage their own users' do
      expect(described_class.new.all_providers_have_at_least_one_user_with_manage_users?).to be_falsy
    end

    it 'returns true if all providers have at least one user with manage_users' do
      @users.second.provider_permissions.second.update(manage_users: true)

      expect(described_class.new.all_providers_have_at_least_one_user_with_manage_users?).to be_truthy
    end
  end
end
