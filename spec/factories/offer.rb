FactoryBot.define do
  factory :offer do
    application_choice { association(:application_choice, :with_offer, offer: instance) }

    conditions { [association(:offer_condition, offer: instance, text: 'Be cool')] }
  end

  factory :unconditional_offer, class: 'Offer', parent: :offer do
    conditions { [] }
  end
end
