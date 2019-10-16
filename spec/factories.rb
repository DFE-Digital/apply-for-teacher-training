FactoryBot.define do
  factory :candidate do
    email_address { "#{SecureRandom.hex}@example.com" }
  end

  factory :application_form do
    candidate

    trait :completed_application_form do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      date_of_birth { Faker::Date.birthday }
      first_nationality { NATIONALITIES.sample }
      second_nationality { NATIONALITIES.sample }
      english_main_language { %w[yes no].sample }
      english_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
      other_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
    end

    factory :completed_application_form, traits: [:completed_application_form]
  end

  factory :application_choice do
    application_form
    status { ApplicationStateChange.valid_states.sample }

    provider_ucas_code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
  end
end
