FactoryBot.define do
  factory :candidate_location_preference do
    candidate_preference factory: %i[candidate_preference]
    name { Faker::Address.city }
    within { 10 }
  end
end
