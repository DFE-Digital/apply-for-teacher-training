require 'rails_helper'

RSpec.describe DataMigrations::UpdateProviderUserSendNotifications do
  describe 'change' do
    let(:provider_user) { create(:provider_user, send_notifications: false) }
    let!(:notification_preferences) do
      create(
        :provider_user_notification_preferences,
        provider_user: provider_user,
        application_received: true,
        application_withdrawn: false,
        application_rejected_by_default: false,
        offer_accepted: false,
        offer_declined: false,
      )
    end

    subject(:migration) { described_class.new }

    it 'updates ProviderUser#send_notifications to true if at least one of the notification preferences is true' do
      migration.change

      expect(provider_user.reload.send_notifications).to be true
    end

    it 'updates ProviderUser#send_notifications to false if all the notification preferences are false' do
      provider_user.update!(send_notifications: false)
      notification_preferences.update!(application_received: false)

      migration.change

      expect(provider_user.reload.send_notifications).to be false
    end

    it 'does nothing if the preferences are the same' do
      notification_preferences.update!(application_received: false)

      allow(provider_user).to receive(:update!)

      migration.change

      expect(provider_user).not_to have_received(:update!)
    end
  end
end
