FactoryBot.define do
  factory :text_condition, class: 'TextCondition' do
    offer

    description { Faker::Lorem.sentence }
    status { 'pending' }
  end
end
