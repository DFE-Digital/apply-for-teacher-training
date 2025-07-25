FactoryBot.define do
  factory :provider_user do
    dfe_sign_in_uid { SecureRandom.uuid }
    email_address { "#{Faker::Name.first_name.downcase}-#{SecureRandom.hex}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    transient do
      create_notification_preference { true }
    end

    after(:create) do |user, evaluator|
      if evaluator.create_notification_preference
        create(:provider_user_notification_preferences, :all_off, provider_user: user)
      end
    end

    trait :with_provider do
      providers do
        [association(:provider, provider_users: [instance])]
      end
    end

    trait :with_dfe_sign_in do
      dfe_sign_in_uid { 'DFE_SIGN_IN_UID' }

      after(:create) do |user, _evaluator|
        create(:provider).provider_users << user
      end
    end

    trait :with_two_providers do
      after(:create) do |user, _evaluator|
        2.times { create(:provider).provider_users << user }
      end
    end

    trait :with_manage_organisations do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(manage_organisations: true)
      end
    end

    trait :with_manage_users do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(manage_users: true)
      end
    end

    trait :with_set_up_interviews do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(set_up_interviews: true)
      end
    end

    trait :with_make_decisions do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(make_decisions: true)
      end
    end

    trait :with_view_safeguarding_information do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(view_safeguarding_information: true)
      end
    end

    trait :with_view_diversity_information do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(view_diversity_information: true)
      end
    end

    trait :with_notifications_enabled do
      after(:create) do |user, _evaluator|
        user.notification_preferences.update_all_preferences(true)
      end
    end

    trait :with_manage_api_tokens do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(manage_api_tokens: true)
      end
    end
  end
end
