FactoryBot.define do
  factory :text_condition, class: 'TextCondition' do
    offer

    text { nil }
    description { Faker::Lorem.sentence }
    status { 'pending' }
  end
end
