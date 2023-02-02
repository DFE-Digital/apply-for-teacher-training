FactoryBot.define do
  factory :subject do
    name { Faker::Educator.subject }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 4) }

    trait :non_language do
      sequence(:name) { |n| "Education #{n}" }
      code { 'G1' }
    end

    trait :language do
      sequence(:name) { |n| "French #{n}" }
      code { '15' }
    end
  end
end
