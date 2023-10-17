FactoryBot.define do
  factory :offer do
    application_choice { association(:application_choice, :offered, offer: instance) }

    conditions { [association(:text_condition, offer: instance)] }

    trait :with_unmet_conditions do
      conditions { [association(:text_condition, :unmet, offer: instance)] }
    end

    trait :with_reference_condition do
      conditions {
        [build(:reference_condition)]
      }
    end

    trait :with_ske_conditions do
      application_choice { association(:application_choice, :pending_conditions, offer: instance) }

      conditions {
        [
          build(:text_condition),
          build(:ske_condition),
        ]
      }
    end
  end

  factory :unconditional_offer, class: 'Offer', parent: :offer do
    conditions { [] }
  end
end
