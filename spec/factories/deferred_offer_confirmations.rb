FactoryBot.define do
  factory :deferred_offer_confirmation do
    provider_user { association :provider_user }
    offer { association :offer }
  end
end
