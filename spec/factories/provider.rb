FactoryBot.define do
  factory :provider do
    initialize_with { Provider.find_or_initialize_by(code: code) }
    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    name { Faker::University.name }

    trait :with_signed_agreement do
      after(:create) do |provider|
        create(:provider_agreement, provider: provider)
      end
    end

    trait :with_user do
      after(:create) do |provider|
        create(:provider_permissions, provider: provider)
      end
    end
  end
end
