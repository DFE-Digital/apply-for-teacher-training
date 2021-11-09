FactoryBot.define do
  factory :feature do
    name { Faker::Lorem.unique.words(number: 3).join('_') }
  end
end
