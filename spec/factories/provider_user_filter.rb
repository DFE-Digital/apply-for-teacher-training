FactoryBot.define do
  factory :provider_user_filter do
    provider_user { build(:provider_user) }

    trait :find_candidates_invited do
      kind { 'find_candidates_invited' }
    end

    trait :find_candidates_all do
      kind { 'find_candidates_all' }
    end
  end
end
