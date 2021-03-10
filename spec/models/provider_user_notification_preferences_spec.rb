require 'rails_helper'

RSpec.describe ProviderUserNotificationPreferences do
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
end
