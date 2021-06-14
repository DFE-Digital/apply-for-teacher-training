require 'rails_helper'

RSpec.describe SaveProviderUserNotificationPreferences do
  let(:create_notification_preference) { false }
  let!(:provider_user) { create(:provider_user, create_notification_preference: create_notification_preference) }

  subject(:service) { described_class.new(provider_user: provider_user) }

  describe 'update_all_notification_preferences!' do
    it 'returns false if no value for #notification_preferences_params is set' do
      expect(service.update_all_notification_preferences!).to be(false)
    end

    context 'when all #notification_preferences_params values are the same' do
      let(:notification_preferences_params) do
        {
          application_received: false,
          application_withdrawn: false,
          application_rejected_by_default: false,
          offer_accepted: false,
          offer_declined: false,
        }
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
