FactoryBot.define do
  factory :candidate do
    email_address { "#{SecureRandom.hex(5)}@example.com" }
  end

  factory :application_form do
    candidate

    factory :completed_application_form do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      date_of_birth { Faker::Date.birthday }
      first_nationality { NATIONALITY_DEMONYMS.sample }
      second_nationality { [nil, NATIONALITY_DEMONYMS.sample].sample }
      english_main_language { %w[true false].sample }
      english_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
      other_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
      further_information { Faker::Lorem.paragraph_by_chars(number: 300) }
      uk_residency_status { 'I have the right to study and/or work in the UK' }
      disclose_disability { %w[true false].sample }
      disability_disclosure { Faker::Lorem.paragraph_by_chars(number: 300) }
      submitted_at { Faker::Time.backward(days: 7, period: :day) }
      phone_number { Faker::PhoneNumber.cell_phone }
      address_line1 { Faker::Address.street_address }
      address_line2 { Faker::Address.city }
      address_line3 { Faker::Address.county }
      address_line4 { '' }
      country { 'UK' }
      postcode { Faker::Address.postcode }
      degrees_completed { [true, false].sample }
      other_qualifications_completed { [true, false].sample }
      becoming_a_teacher { Faker::Lorem.paragraph_by_chars(number: 500) }
      subject_knowledge { Faker::Lorem.paragraph_by_chars(number: 300) }
      interview_preferences { Faker::Lorem.paragraph_by_chars(number: 100) }
      work_history_explanation { Faker::Lorem.paragraph_by_chars(number: 600) }
      work_history_breaks { Faker::Lorem.paragraph_by_chars(number: 400) }

      transient do
        application_choices_count { 3 }
        work_experiences_count { 1 }
        volunteering_experiences_count { 1 }
        qualifications_count { 4 }
        references_count { 2 }
      end

      after(:build) do |application_form, evaluator|
        create_list(:application_choice, evaluator.application_choices_count, application_form: application_form)
        create_list(:application_work_experience, evaluator.work_experiences_count, application_form: application_form)
        create_list(:application_volunteering_experience, evaluator.volunteering_experiences_count, application_form: application_form)
        create_list(:application_qualification, evaluator.qualifications_count, application_form: application_form)
        create_list(:reference, evaluator.references_count, application_form: application_form)
        # The application_form validates the length of this collection when
        # it is created, which is BEFORE we create the references here.
        # This then *caches* the association on the  application_form, and means
        # you have to explicitly reload it to pick up the created references.
        # We do this here, so we only have to do it in one place, rather than
        # everywhere we refer to application_form.references in tests.
        # See https://github.com/thoughtbot/factory_bot/issues/549 for details.
        application_form.references.reload
      end
    end
  end

  factory :application_experience do
    role { ['Teacher', 'Teaching Assistant'].sample }
    organisation { Faker::Educator.secondary_school }
    details { Faker::Lorem.paragraph_by_chars(number: 300) }
    working_with_children { [true, true, true, false].sample }
    start_date { Faker::Date.between(from: 20.years.ago, to: 5.years.ago) }
    end_date { [Faker::Date.between(from: 4.years.ago, to: Date.today), nil].sample }
    commitment { %w[full_time part_time].sample }
  end

  factory :application_volunteering_experience, parent: :application_experience, class: 'ApplicationVolunteeringExperience'
  factory :application_work_experience, parent: :application_experience, class: 'ApplicationWorkExperience'

  factory :application_qualification do
    level { %w[degree gcse other].sample }
    qualification_type { %w[BA Masters A-Level GCSE].sample }
    subject { Faker::Educator.subject }

    grade { %w[first upper_second A B].sample }
    predicted_grade { %w[true false].sample }
    award_year { Faker::Date.between(from: 60.years.ago, to: 3.years.from_now).year }
    institution_name { Faker::Educator.university }
    institution_country { Faker::Address.country_code }
    awarding_body { Faker::Educator.university }
    equivalency_details { Faker::Lorem.paragraph_by_chars(number: 200) }
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

    code { Faker::Alphanumeric.alphanumeric(number: 4, min_alpha: 1).upcase }
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

    trait :single do
      association :application_form, factory: :completed_application_form, application_choices_count: 0
    end
  end

  factory :vendor_api_user do
    association :vendor_api_token
    full_name { 'Bob' }
    email_address { 'bob@example.com' }
    vendor_user_id { '123' }
  end

  factory :vendor_api_token do
    association :provider
    hashed_token { '1234567890' }
  end

  factory :reference do
    email_address { "#{SecureRandom.hex(5)}@example.com" }
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    relationship { Faker::Lorem.words(number: 10) }

    trait :unsubmitted do
      feedback { nil }
    end

    trait :complete do
      feedback { Faker::Lorem.paragraphs(number: 2) }
    end
  end

  factory :sign_up_form do
    email_address { "#{SecureRandom.hex(5)}@example.com" }
    accept_ts_and_cs { true }
  end
end
