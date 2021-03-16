require 'rails_helper'

RSpec.describe SaveProviderUserNotificationPreferences do
  describe 'save!' do
    let(:provider_user) { create(:provider_user, send_notifications: false) }

    subject(:service) { described_class.new(provider_user: provider_user, notification_params: { send_notifications: true }) }

    it 'updates #send_notifications for a provider user' do
      service.call!

      expect(provider_user.send_notifications).to be true
    end

    it 'updates #notification_preferences for a provider user' do
      service.call!

      ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |pref|
        expect(provider_user.notification_preferences.send(pref)).to be true
      end
    end

    it 'creates and updates #notification_preferences for a provider user with no preferences' do
      # Remove the notification preferences to emulate an existing user with no association set up yet.
      provider_user.notification_preferences.delete
      provider_user.reload

      service.call!

      provider_user.reload

      ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |pref|
        expect(provider_user.notification_preferences.send(pref)).to be true
      end
    end
  end
end
