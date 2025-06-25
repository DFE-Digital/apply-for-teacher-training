FactoryBot.define do
  factory :provider_user_filter do
    provider_user

    trait :find_candidates_all do
      path { 'find_candidates_all' }
    end

    trait :find_candidates_not_seen do
      path { 'find_candidates_not_seen' }
    end
  end
end
