FactoryBot.define do
  factory :reference_token do
    association :application_reference, factory: :reference

    hashed_token { '1234567890' }
  end
end
