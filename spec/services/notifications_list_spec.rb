require 'rails_helper'

RSpec.describe NotificationsList do
  describe '.for' do
    it 'returns provider users for the application choice' do
      application_choice = create(:application_choice)

      create(:provider_user, send_notifications: false, providers: [application_choice.course.provider])
      create(:provider_user, send_notifications: true)
      provider_user = create(:provider_user, send_notifications: true, providers: [application_choice.course.provider])

      expect(NotificationsList.for(application_choice).to_a).to eql([provider_user])
    end
  end
end
