FactoryBot.define do
  factory :text_condition, parent: :offer_condition, class: 'TextCondition' do
    offer

    text { nil }
    description { Faker::Lorem.sentence }
  end
end
