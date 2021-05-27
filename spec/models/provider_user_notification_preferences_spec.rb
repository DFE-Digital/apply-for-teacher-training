require 'rails_helper'

RSpec.describe ProviderUserNotificationPreferences do
  describe '#update_all_preferences' do
    let(:notification_preferences) { create(:provider_user_notification_preferences) }

    it 'updates all types of notification preferences' do
      notification_preferences = create(:provider_user_notification_preferences)
      notification_preferences.update_all_preferences(false)

      described_class::NOTIFICATION_PREFERENCES.each do |type|
        expect(notification_preferences.send(type)).to eq(false)
      end
    end
  end

  describe '.notification_preference_exists?' do
    let(:notification_preferences) { build(:provider_user_notification_preferences) }

    it 'returns true for defined notification preferences types' do
      described_class::NOTIFICATION_PREFERENCES.each do |type|
        expect(described_class.notification_preference_exists?(type)).to eq(true)
      end
    end

    it 'returns false if the notification type is not defined' do
      expect(described_class.notification_preference_exists?(:application_exploded)).to eq(false)
    end
  end

  describe 'auditing' do
    it 'updating adds an audit entry related to the provider_user', with_audited: true do
      notification_preferences = create(:provider_user_notification_preferences)
      notification_preferences.update(application_withdrawn: false)

      audit = notification_preferences.provider_user.associated_audits.last

      expect(notification_preferences.provider_user.associated_audits.count).to eq(1)
      expect(audit.audited_changes['application_withdrawn']).to eq([true, false])
    end
  end
end
