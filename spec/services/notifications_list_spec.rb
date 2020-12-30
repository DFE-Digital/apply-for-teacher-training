require 'rails_helper'

RSpec.describe NotificationsList do
  let(:application_choice) { create(:application_choice) }
  let!(:user_with_notifications) { create(:provider_user, send_notifications: true, providers: [application_choice.course.provider]) }
  let!(:user_without_notifications) { create(:provider_user, send_notifications: false, providers: [application_choice.course.provider]) }

  before do
    create(:provider_user, send_notifications: true)
    create(:provider_user, send_notifications: false)
  end

  describe '.for' do
    it 'returns the application choice provider users with notifications disabled' do
      expect(described_class.for(application_choice).to_a).to eql([user_with_notifications])
    end
  end

  describe '.off_for' do
    it 'returns the application choice provider users with notifications disabled' do
      expect(described_class.off_for(application_choice).to_a).to eql([user_without_notifications])
    end
  end
end
