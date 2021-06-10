FactoryBot.define do
  factory :offer do
    application_choice

    conditions { [association(:offer_condition, offer: instance)] }
  end

  factory :unconditional_offer, class: 'Offer' do
    application_choice
  end
end
