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
      first_nationality { NATIONALITY_DEMONYMS.sample }
      second_nationality { NATIONALITY_DEMONYMS.sample }
      english_main_language { %w[true false].sample }
      english_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
      other_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
      further_information { %w[true false].sample }
      further_information_details { Faker::Lorem.paragraph_by_chars(number: 300) }

      transient do
        application_choices_count { 3 }
      end
    end

    factory :completed_application_form, traits: [:completed_application_form] do
      after(:build) do |application_form, evaluator|
        create_list(:application_choice, evaluator.application_choices_count, application_form: application_form)
      end
    end
  end

  factory :course do
    provider

    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    name { Faker::Educator.subject }
  end

  factory :provider do
    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    name { Faker::Educator.university }
  end

  factory :application_choice do
    association :application_form, factory: :completed_application_form
    course
    status { ApplicationStateChange.valid_states.sample }
  end
end
