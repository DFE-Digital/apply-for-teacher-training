FactoryBot.define do
  factory :offer do
    application_choice { association(:application_choice, :offered, offer: instance) }

    conditions { [association(:offer_condition, offer: instance)] }

    trait :with_unmet_conditions do
      conditions { [association(:offer_condition, :unmet, offer: instance)] }
    end
  end

  factory :unconditional_offer, class: 'Offer', parent: :offer do
    conditions { [] }
  end
end
