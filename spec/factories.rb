FactoryBot.define do
  factory :candidate do
    email_address { "#{SecureRandom.hex}@example.com" }
  end

  factory :application_form do
    candidate
  end

  factory :application_choice do
    provider_ucas_code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    application_form
    status { :application_complete }
  end
end
