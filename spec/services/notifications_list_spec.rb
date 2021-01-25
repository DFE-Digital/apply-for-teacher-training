require 'rails_helper'

RSpec.describe NotificationsList do
  describe '.for' do
    it 'returns training provider users for the application choice by default' do
      application_choice = create(:application_choice)

      create(:provider_user, send_notifications: false, providers: [application_choice.course.provider])
      create(:provider_user, send_notifications: true)
      provider_user = create(:provider_user, send_notifications: true, providers: [application_choice.course.provider])

      expect(NotificationsList.for(application_choice).to_a).to eql([provider_user])
    end

    it 'returns training and ratifying provider users for the application choice when specified' do
      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, send_notifications: true, providers: [ratifying_provider])
      application_choice = create(:application_choice, course_option: create(:course_option, course: create(:course, accredited_provider: ratifying_provider)))

      create(:provider_user, send_notifications: false, providers: [application_choice.course.provider])
      create(:provider_user, send_notifications: true)
      training_provider_user = create(:provider_user, send_notifications: true, providers: [application_choice.course.provider])

      expect(NotificationsList.for(application_choice, include_ratifying_provider: true).to_a).to match_array([training_provider_user, ratifying_provider_user])
    end
  end
end
