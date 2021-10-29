FactoryBot.define do
  factory :provider do
    initialize_with { Provider.find_or_initialize_by(code: code) }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 3).upcase }
    name { Faker::University.name }
    region_code { 'london' }

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

    trait :with_vendor do
      before(:create) do |provider|
        provider.vendor = Vendor.find_or_create_by(name: 'in_house')
      end
    end
  end
end
