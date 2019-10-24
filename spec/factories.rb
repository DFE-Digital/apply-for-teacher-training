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

      phone_number { Faker::PhoneNumber.cell_phone }
      address_line1 { Faker::Address.street_name }
      address_line2 { Faker::Address.street_address }
      address_line3 { Faker::Address.city }
      address_line4 { Faker::Address.country }
      country { Faker::Address.country_code }
      postcode { Faker::Address.postcode }

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

  factory :site do
    provider

    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    name { Faker::Educator.secondary_school }
  end

  factory :course_option do
    course
    site do
      association(:site, provider: course.provider)
    end

    vacancy_status { 'B' }
  end

  factory :course do
    provider

    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    name { Faker::Educator.subject }
    level { 'primary' }
    start_date { Date.new(2020, 9, 1) }
  end

  factory :provider do
    initialize_with { Provider.find_or_create_by code: code }
    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    name { Faker::Educator.university }
  end

  factory :application_choice do
    association :application_form, factory: :completed_application_form
    course_option
    status { ApplicationStateChange.valid_states.sample }
    personal_statement { 'hello' }
  end

  factory :vendor_api_user do
    association :vendor_api_token
    full_name { 'Bob' }
    email { 'bob@example.com' }
    user_id { '123' }
  end

  factory :vendor_api_token do
    association :provider
    hashed_token { '1234567890' }
  end
end
