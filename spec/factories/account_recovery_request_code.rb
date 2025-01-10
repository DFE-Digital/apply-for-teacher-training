FactoryBot.define do
  factory :account_recovery_request_code do
    account_recovery_request { association(:account_recovery_request) }
    code { Array.new(6) { rand(0..9) }.join }
  end
end
