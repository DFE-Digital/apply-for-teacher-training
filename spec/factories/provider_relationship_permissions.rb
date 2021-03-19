FactoryBot.define do
  factory :provider_relationship_permissions do
    ratifying_provider { build(:provider) }
    training_provider { build(:provider) }
    training_provider_can_make_decisions { true }
    training_provider_can_view_safeguarding_information { true }
    training_provider_can_view_diversity_information { true }
    setup_at { Time.zone.now }

    trait :not_set_up_yet do
      training_provider_can_make_decisions { false }
      training_provider_can_view_safeguarding_information { false }
      training_provider_can_view_diversity_information { false }
      setup_at { nil }
    end
  end
end
