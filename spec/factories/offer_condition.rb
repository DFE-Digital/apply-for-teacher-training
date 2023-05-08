FactoryBot.define do
  factory :offer_condition do
    offer

    status { 'pending' }
  end
end
