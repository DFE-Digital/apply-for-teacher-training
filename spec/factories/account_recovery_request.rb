FactoryBot.define do
  factory :account_recovery_request do
    candidate { association(:candidate) }
  end
end
