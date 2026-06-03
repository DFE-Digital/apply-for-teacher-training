require 'rails_helper'

RSpec.describe RemoveInactiveProviderUsersWorker do
  describe '#perform' do
    it 'revokes inactive provider users permissions except those re-added within the last week' do
      should_revoke = create(:provider_user, :with_provider, last_signed_in_at: 12.months.ago - 1.day)
      should_revoke.provider_permissions.update_all(created_at: 12.weeks.ago)

      account_never_used = create(:provider_user, :with_provider, last_signed_in_at: nil, created_at: 12.months.ago - 1.day)
      account_never_used.provider_permissions.update_all(created_at: 2.weeks.ago)

      should_not_revoke = create(:provider_user, :with_provider, last_signed_in_at: 8.months.ago)
      should_not_revoke.provider_permissions.update_all(created_at: 2.weeks.ago)

      account_created_now = create(:provider_user, :with_provider, last_signed_in_at: nil)
      account_created_now.provider_permissions.update_all(created_at: 2.weeks.ago)

      recently_readded = create(:provider_user, :with_provider, last_signed_in_at: 12.months.ago - 1.day)
      recently_readded.provider_permissions.update_all(created_at: 2.days.ago)

      expect { described_class.new.perform }.to change { ProviderPermissions.count }.by(-2)
      expect(should_revoke.provider_permissions).to eq([])
      expect(account_never_used.provider_permissions).to eq([])
      expect(should_not_revoke.provider_permissions.exists?).to be(true)
      expect(account_created_now.provider_permissions.exists?).to be(true)
      expect(recently_readded.provider_permissions.exists?).to be(true)
    end
  end
end
