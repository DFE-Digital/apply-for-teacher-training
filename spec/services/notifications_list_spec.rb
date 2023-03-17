require 'rails_helper'

RSpec.describe NotificationsList do
  describe '.for' do
    it 'raises an error for an undefined type of event' do
      application_choice = build(:application_choice)

      expect { described_class.for(application_choice, event: 'application_exploded') }.to raise_error('Undefined type of notification event')
    end

    it 'returns empty array for blank application choices' do
      expect(
        described_class.for(
          nil,
          event: :reference_received,
        ).to_a,
      ).to eql([])
    end

    it 'returns training provider users for the application choice for a given type of event' do
      application_choice = create(:application_choice)
      provider_user = create(:provider_user, :with_notifications_enabled, providers: [application_choice.course.provider])

      create(:provider_user_notification_preferences, :all_off, provider_user: create(:provider_user, providers: [application_choice.course.provider]))

      expect(described_class.for(application_choice, event: :offer_accepted).to_a).to eql([provider_user])
    end

    it 'does not return training provider users for a disabled chase_provider_decision preference' do
      application_choice = create(:application_choice)
      provider_user = create(:provider_user, :with_notifications_enabled, providers: [application_choice.course.provider])

      create(:provider_user_notification_preferences, chase_provider_decision: false, provider_user: create(:provider_user, providers: [application_choice.course.provider]))

      expect(described_class.for(application_choice, event: :chase_provider_decision).to_a).to eql([provider_user])
    end

    it 'returns training and ratifying provider users for the application choice for a given type of event' do
      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])

      application_choice = create(:application_choice, course_option: create(:course_option, course: create(:course, accredited_provider: ratifying_provider)))

      training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [application_choice.course.provider])

      create(:provider_user_notification_preferences, :all_off, provider_user: create(:provider_user, providers: [application_choice.course.provider]))
      expect(described_class.for(application_choice, include_ratifying_provider: true, event: :offer_accepted).to_a).to contain_exactly(training_provider_user, ratifying_provider_user)
    end

    it 'returns a provider user who is a member of the training and ratifying providers without duplicates' do
      ratifying_provider = create(:provider)
      training_provider = create(:provider)
      provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider, ratifying_provider])
      application_choice = create(:application_choice, course_option: create(:course_option, course: create(:course, provider: training_provider, accredited_provider: ratifying_provider)))

      expect(described_class.for(
        application_choice,
        include_ratifying_provider: true,
        event: :offer_accepted,
      ).to_a).to contain_exactly(provider_user)
    end
  end
end
