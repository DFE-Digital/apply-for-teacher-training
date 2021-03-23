require 'rails_helper'

RSpec.describe DataMigrations::UpsertProviderUserSendNotifications do
  describe 'change' do
    let(:provider_user) { create(:provider_user, send_notifications: true) }
    let(:another_provider_user) { create(:provider_user, send_notifications: true) }
    let(:notification_preferences) do
      create(
        :provider_user_notification_preferences,
        provider_user: provider_user,
        application_received: false,
        application_withdrawn: false,
        application_rejected_by_default: false,
        offer_accepted: false,
        offer_declined: false,
      )
    end

    subject(:migration) { described_class.new }

    before do
      provider_user.notification_preferences.delete
      provider_user.update!(notification_preferences: notification_preferences)
      another_provider_user.notification_preferences.delete
    end

    it 'updates existing ProviderUserNotificationPreferences with the ProviderUser#send_notifications value' do
      migration.change

      notification_preferences.reload

      expect(notification_preferences.application_received).to be true
      expect(notification_preferences.application_withdrawn).to be true
      expect(notification_preferences.application_rejected_by_default).to be true
      expect(notification_preferences.offer_accepted).to be true
      expect(notification_preferences.offer_declined).to be true
    end

    it 'inserts new ProviderUserNotificationPreferences' do
      expect { migration.change }.to change(ProviderUserNotificationPreferences, :count).by(1)

      expect(another_provider_user.notification_preferences.application_received).to be true
      expect(another_provider_user.notification_preferences.application_withdrawn).to be true
      expect(another_provider_user.notification_preferences.application_rejected_by_default).to be true
      expect(another_provider_user.notification_preferences.offer_accepted).to be true
      expect(another_provider_user.notification_preferences.offer_declined).to be true
    end
  end
end
