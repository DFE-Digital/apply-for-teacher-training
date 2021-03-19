FactoryBot.define do
  factory :provider_user do
    dfe_sign_in_uid { SecureRandom.uuid }
    email_address { "#{Faker::Name.first_name.downcase}-#{SecureRandom.hex}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    send_notifications { Faker::Boolean.boolean(true_ratio: 0.5) }

    after(:create) do |user, _evaluator|
      user.send_notifications ? create(:provider_user_notification_preferences, provider_user: user) : create(:provider_user_notification_preferences, :all_off, provider_user: user)
    end

    trait :with_provider do
      after(:create) do |user, _evaluator|
        create(:provider).provider_users << user
      end
    end

    trait :with_dfe_sign_in do
      dfe_sign_in_uid { 'DFE_SIGN_IN_UID' }

      after(:create) do |user, _evaluator|
        create(:provider, :with_signed_agreement).provider_users << user
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
  end
end
