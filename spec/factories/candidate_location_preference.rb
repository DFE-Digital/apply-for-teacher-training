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

    trait :liverpool do
      name { 'Liverpool' }
      latitude { 53.3991849 }
      longitude { -2.9924405 }
    end
  end
end
