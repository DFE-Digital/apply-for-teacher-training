require 'rails_helper'

RSpec.describe NotificationsList do
  describe '.for' do
    context 'when the configurable provider notifications feature flag is on' do
      before { FeatureFlag.activate(:configurable_provider_notifications) }

      it 'raises an error for an undefined type of event' do
        application_choice = build(:application_choice)

        expect { NotificationsList.for(application_choice, event: 'application_exploded') }.to raise_error('Undefined type of notification event')
      end

      it 'returns training provider users for the application choice for a given type of event' do
        application_choice = create(:application_choice)

        create(:provider_user_notification_preferences, :all_off, provider_user: create(:provider_user, send_notifications: false, providers: [application_choice.course.provider]))
        create(:provider_user_notification_preferences)

        provider_user = create(:provider_user, send_notifications: true, providers: [application_choice.course.provider])

        expect(NotificationsList.for(application_choice, event: :offer_accepted).to_a).to eql([provider_user])
      end

      it 'returns training and ratifying provider users for the application choice for a given type of event' do
        ratifying_provider = create(:provider)
        ratifying_provider_user = create(:provider_user, send_notifications: true, providers: [ratifying_provider])

        application_choice = create(:application_choice, course_option: create(:course_option, course: create(:course, accredited_provider: ratifying_provider)))

        training_provider_user = create(:provider_user, send_notifications: true, providers: [application_choice.course.provider])

        create(:provider_user_notification_preferences, :all_off, provider_user: create(:provider_user, send_notifications: false, providers: [application_choice.course.provider]))
        create(:provider_user_notification_preferences)

        expect(NotificationsList.for(application_choice, include_ratifying_provider: true, event: :offer_accepted).to_a).to match_array([training_provider_user, ratifying_provider_user])
      end

      it 'returns a provider user who is a member of the training and ratifying providers without duplicates' do
        ratifying_provider = create(:provider)
        training_provider = create(:provider)
        provider_user = create(:provider_user, send_notifications: true, providers: [training_provider, ratifying_provider])
        application_choice = create(:application_choice, course_option: create(:course_option, course: create(:course, provider: training_provider, accredited_provider: ratifying_provider)))

        create(
          :provider_user_notification_preferences,
          :all_off,
          provider_user: create(:provider_user, send_notifications: false, providers: [training_provider, ratifying_provider]),
        )
        create(:provider_user_notification_preferences)

        expect(NotificationsList.for(
          application_choice,
          include_ratifying_provider: true,
          event: :offer_accepted,
        ).to_a).to match_array([provider_user])
      end
    end

    context 'when the configurable provider notifications feature flag is off' do
      before { FeatureFlag.deactivate(:configurable_provider_notifications) }

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

      it 'returns a provider user who is a member of the training and ratifying providers without duplicates' do
        ratifying_provider = create(:provider)
        training_provider = create(:provider)
        provider_user = create(:provider_user, send_notifications: true, providers: [training_provider, ratifying_provider])
        application_choice = create(:application_choice, course_option: create(:course_option, course: create(:course, provider: training_provider, accredited_provider: ratifying_provider)))

        create(
          :provider_user_notification_preferences,
          :all_off,
          provider_user: create(:provider_user, send_notifications: false, providers: [training_provider, ratifying_provider]),
        )
        create(:provider_user_notification_preferences)

        expect(NotificationsList.for(
          application_choice,
          include_ratifying_provider: true,
          event: :offer_accepted,
        ).to_a).to match_array([provider_user])
      end
    end
  end
end
