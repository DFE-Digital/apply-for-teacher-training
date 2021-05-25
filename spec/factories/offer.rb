FactoryBot.define do
  factory :offer do
    application_choice

    conditions { [association(:offer_condition, offer: instance)] }
  end
end
