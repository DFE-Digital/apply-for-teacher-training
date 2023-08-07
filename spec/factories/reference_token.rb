FactoryBot.define do
  factory :reference_token do
    application_reference factory: %i[reference]

    hashed_token { '1234567890' }
  end
end
