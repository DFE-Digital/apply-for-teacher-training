FactoryBot.define do
  factory :candidate_location_preference do
    candidate_preference factory: %i[candidate_preference]
    name { Faker::Address.city }
    within { 10 }

    trait :manchester do
      name { 'Manchester' }
      latitude { 53.9807593 }
      longitude { -2.9426305 }
    end
  end
end
