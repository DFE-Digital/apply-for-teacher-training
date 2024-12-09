FactoryBot.define do
  factory :one_login_auth do
    candidate
    token { SecureRandom.hex(10) }
    email_address { "#{SecureRandom.hex(5)}@example.com" }
  end
end
