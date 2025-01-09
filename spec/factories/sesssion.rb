FactoryBot.define do
  factory :session do
    candidate { association(:candidate) }
    id_token_hint { SecureRandom.hex }
  end
end
