FactoryBot.define do
  factory :candidate_preference do
    candidate factory: %i[candidate]
    pool_status { 'opt_in' }
    dynamic_location_preferences { true }
  end
end
