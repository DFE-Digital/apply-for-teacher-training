FactoryBot.define do
  factory :candidate_location_preference do
    candidate_preference factory: %i[candidate_preference]
    name { Faker::Address.city }
    within { 10 }

    trait :manchester do
      name { 'Manchester' }
      latitude { 53.4807593 }
      longitude { -2.2426305 }
    end
  end
end
