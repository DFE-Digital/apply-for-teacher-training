FactoryBot.define do
  factory :offer_condition do
    offer

    text { Faker::Lorem.sentence }
    status { 'pending' }
  end
end
