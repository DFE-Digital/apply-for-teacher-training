FactoryBot.define do
  factory :deferred_offer_confirmation do
    provider_user { association :provider_user }
    offer { association :offer }
    offered_course_option { offer.application_choice.current_course_option }

    initialize_with { new(provider_user:, offer:, offered_course_option:) }
  end
end
