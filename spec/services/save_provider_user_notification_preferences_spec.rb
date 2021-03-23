require 'rails_helper'

RSpec.describe SaveProviderUserNotificationPreferences do
  let(:create_notification_preference) { false }
  let(:send_notifications) { false }
  let!(:provider_user) { create(:provider_user, create_notification_preference: create_notification_preference, send_notifications: send_notifications) }

  subject(:service) { described_class.new(provider_user: provider_user) }

  describe 'backfill_notification_preferences!' do
    it 'returns false if no value for #send_notifications is set' do
      expect(service.backfill_notification_preferences!(send_notifications: nil)).to be(false)
    end

    context 'when no notification preferences exist for a provider user' do
      it 'updates #send_notifications for a provider user' do
        service.backfill_notification_preferences!(send_notifications: true)

        expect(provider_user.send_notifications).to be(true)
      end

      it 'creates the #notification_preferences for the provider user' do
        expect { service.backfill_notification_preferences!(send_notifications: true) }.to change(ProviderUserNotificationPreferences, :count).by(1)
      end

      it 'sets the correct value for the #notification_preferences for a provider user' do
        service.backfill_notification_preferences!(send_notifications: true)

        ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |preference|
          expect(provider_user.reload.notification_preferences.send(preference)).to be(true)
        end
      end
    end

    context 'when notification preferences exist for a user' do
      let(:create_notification_preference) { true }

      it 'updates #send_notifications for a provider user' do
        service.backfill_notification_preferences!(send_notifications: true)

        expect(provider_user.send_notifications).to be(true)
      end

      it 'does not create #notification_preferences for a provider user' do
        expect { service.backfill_notification_preferences!(send_notifications: true) }.not_to change(ProviderUserNotificationPreferences, :count)
      end

      it 'sets the correct value for the #notification_preferences for a provider user' do
        service.backfill_notification_preferences!(send_notifications: true)

        ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |preference|
          expect(provider_user.reload.notification_preferences.send(preference)).to be(true)
        end
      end
    end

    context 'when send notification preference is unchanged' do
      let(:send_notifications) { false }

      it 'does not update #send_notifications for a provider user' do
        expect { service.backfill_notification_preferences!(send_notifications: false) }.not_to change(provider_user, :send_notifications)
        expect(provider_user.send_notifications).to be(false)
      end

      it 'sets the correct value for the #notification_preferences for a provider user' do
        service.backfill_notification_preferences!(send_notifications: false)

        ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |preference|
          expect(provider_user.reload.notification_preferences.send(preference)).to be(false)
        end
      end
    end
  end

  describe 'update_all_notification_preferences!' do
    it 'returns false if no value for #notification_preferences_params is set' do
      expect(service.update_all_notification_preferences!).to be(false)
    end

    context 'when all #notification_preferences_params values are the same' do
      let(:send_notifications) { true }
      let(:notification_preferences_params) do
        {
          application_received: false,
          application_withdrawn: false,
          application_rejected_by_default: false,
          offer_accepted: false,
          offer_declined: false,
        }
      end

      it 'updates #send_notifications for a provider user' do
        service.update_all_notification_preferences!(notification_preferences_params: notification_preferences_params)

        expect(provider_user.send_notifications).to be(false)
      end

      it 'sets the correct value for the #notification_preferences for a provider user' do
        service.update_all_notification_preferences!(notification_preferences_params: notification_preferences_params)

        ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |preference|
          expect(provider_user.reload.notification_preferences.send(preference)).to be(false)
        end
      end
    end

    context 'when #notification_preferences_params values are different' do
      let(:notification_preferences_params) do
        {
          application_received: true,
          application_withdrawn: false,
          application_rejected_by_default: false,
          offer_accepted: true,
          offer_declined: false,
        }
      end

      it 'updates #send_notifications for a provider user' do
        service.update_all_notification_preferences!(notification_preferences_params: notification_preferences_params)

        expect(provider_user.send_notifications).to be(true)
      end

      it 'sets the correct value for the #notification_preferences for a provider user' do
        service.update_all_notification_preferences!(notification_preferences_params: notification_preferences_params)

        expect(provider_user.reload.notification_preferences.attributes).to include(
          'application_received' => true,
          'application_withdrawn' => false,
          'application_rejected_by_default' => false,
          'offer_accepted' => true,
          'offer_declined' => false,
        )
      end
    end
  end
end
