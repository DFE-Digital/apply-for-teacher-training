FactoryBot.define do
  factory :candidate_preference do
    candidate factory: %i[candidate]
    pool_status { 'opt_in' }
    dynamic_location_preferences { true }
    status { 'published' }
    training_locations { 'specific' }

    trait :opt_in_manchester do
      after(:create) do |candidate_preference|
        create(
          :candidate_location_preference,
          :manchester,
          candidate_preference:,
        )
      end
    end
  end
end
