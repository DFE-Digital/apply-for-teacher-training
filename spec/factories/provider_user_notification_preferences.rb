FactoryBot.define do
  factory :provider_user_notification_preferences do
    provider_user

    application_received { true }
    application_withdrawn { true }
    application_rejected_by_default { true }
    offer_accepted { true }
    offer_declined { true }

    trait :all_off do
      application_received { false }
      application_withdrawn { false }
      application_rejected_by_default { false }
      offer_accepted { false }
      offer_declined { false }
    end
  end
end
