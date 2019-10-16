FactoryBot.define do
  factory :candidate do
    email_address { "#{SecureRandom.hex}@example.com" }
  end

  factory :application_form do
    candidate

    date_of_birth { Faker::Date.birthday }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end

  factory :application_choice do
    application_form

    provider_ucas_code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    status { :application_complete }
  end
end
