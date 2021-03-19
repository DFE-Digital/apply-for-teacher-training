FactoryBot.define do
  factory :vendor_api_token do
    provider

    hashed_token { '1234567890' }

    trait :with_random_token do
      hashed_token do
        _unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token)
        hashed_token
      end
    end
  end
end
