FactoryBot.define do
  factory :authentication_token do
    user { create(:support_user) }
    hashed_token { SecureRandom.uuid }
  end
end
