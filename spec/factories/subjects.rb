FactoryBot.define do
  factory :subject do
    name { Faker::Educator.subject }
    code { Faker::Alphanumeric.alphanumeric(number: 4) }
  end
end
