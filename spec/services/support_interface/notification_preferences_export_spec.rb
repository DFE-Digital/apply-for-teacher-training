require 'rails_helper'

RSpec.describe SupportInterface::NotificationPreferencesExport do
  let(:provider1) { create(:provider) }
  let(:provider2) { create(:provider) }
  let(:provider_user1) { create(:provider_user, providers: [provider1, provider2]) }
  let(:provider_user2) { create(:provider_user, providers: [provider2]) }

  before do
    provider_user1.provider_permissions.where(provider: provider2).update(make_decisions: true)
    create(:provider_user_notification_preferences, provider_user: provider_user1)
    provider_user2.provider_permissions.where(provider: provider2).update(make_decisions: true)
    create(:provider_user_notification_preferences, provider_user: provider_user2)

    create(:provider_user_notification_preferences_audit, notification_preferences: provider_user1.notification_preferences, changes: {
      'application_received' => [true, false], 'offer_accepted' => [false, true], 'offer_declined' => [true, false]
    })
    create(:provider_user_notification_preferences_audit, notification_preferences: provider_user2.notification_preferences, changes: {
      'application_withdrawn' => [true, false], 'application_rejected_by_default' => [false, true], 'offer_accepted' => [true, false]
    })
    create(:provider_user_notification_preferences_audit, notification_preferences: provider_user2.notification_preferences, changes: {
      'application_received' => [true, false], 'offer_accepted' => [true, false]
    })
  end

  it_behaves_like 'a data export'

  describe '#data_for_export' do
    it 'exports changes to provider user notification preferences' do
      expect(described_class.new.data_for_export).to match_array([
        {
          provider_user_id: provider_user1.id,
          provider_code: provider1.code,
          permissions_make_decisions: false,
          changed_at: anything,
          notifications_added: 'offer_accepted',
          notifications_removed: 'application_received, offer_declined',
        },
        {
          provider_user_id: provider_user1.id,
          provider_code: provider2.code,
          permissions_make_decisions: true,
          changed_at: anything,
          notifications_added: 'offer_accepted',
          notifications_removed: 'application_received, offer_declined',
        },
        {
          provider_user_id: provider_user2.id,
          provider_code: provider2.code,
          permissions_make_decisions: true,
          changed_at: anything,
          notifications_added: '',
          notifications_removed: 'application_received, offer_accepted',
        },
        {
          provider_user_id: provider_user2.id,
          provider_code: provider2.code,
          permissions_make_decisions: true,
          changed_at: anything,
          notifications_added: 'application_rejected_by_default',
          notifications_removed: 'application_withdrawn, offer_accepted',
        },
      ])
    end
  end
end
