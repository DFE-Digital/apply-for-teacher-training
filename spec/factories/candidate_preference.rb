FactoryBot.define do
  factory :candidate_preference do
    application_form factory: %i[application_form]
    candidate { application_form.candidate }
    pool_status { 'opt_in' }
    dynamic_location_preferences { true }
    status { 'published' }
    training_locations { 'specific' }
    funding_type { 'fee' }
  end

  trait :anywhere_in_england do
    training_locations { 'anywhere' }
    dynamic_location_preferences { nil }
  end

  trait :specific_locations do
    training_locations { 'specific' }
  end

  trait :opt_out do
    pool_status { 'opt_out' }
    dynamic_location_preferences { nil }
    training_locations { nil }
    funding_type { nil }
    opt_out_reason { 'I do not want to receive invites' }
  end
end
