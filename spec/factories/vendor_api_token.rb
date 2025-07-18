FactoryBot.define do
  factory :vendor_api_token do
    provider

    hashed_token { SecureRandom.hex(16) }

    trait :with_random_token do
      hashed_token do
        _unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token)
        hashed_token
      end
    end

    trait :with_last_used_at do
      last_used_at { 2.days.ago }
    end
  end
end
