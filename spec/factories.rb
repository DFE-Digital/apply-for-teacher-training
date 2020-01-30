FactoryBot.define do
  factory :chaser_sent do
    candidate
    chased_id { candidate.id }
    chased_type { candidate.class }
    chased_type { :referee_mailer_reference_request_chaser_email }
  end

  factory :candidate do
    email_address { "#{SecureRandom.hex(5)}@example.com" }
    sign_up_email_bounced { false }
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
      country { 'GB' }
      postcode { Faker::Address.postcode }
      becoming_a_teacher { Faker::Lorem.paragraph_by_chars(number: 500) }
      subject_knowledge { Faker::Lorem.paragraph_by_chars(number: 300) }
      interview_preferences { Faker::Lorem.paragraph_by_chars(number: 100) }
      work_history_explanation { Faker::Lorem.paragraph_by_chars(number: 600) }
      work_history_breaks { Faker::Lorem.paragraph_by_chars(number: 400) }
      volunteering_experience { [true, false, nil].sample }

      # Checkboxes to mark a section as complete
      course_choices_completed { true }
      degrees_completed { true }
      other_qualifications_completed { true }
      volunteering_completed { true }
      work_history_completed { true }

      transient do
        application_choices_count { 0 }
        work_experiences_count { 0 }
        volunteering_experiences_count { 0 }
        references_count { 0 }
        references_state { :unsubmitted }
        with_gces { false }
      end

      trait :with_completed_references do
        transient do
          references_state { :complete }
        end
      end

      after(:build) do |application_form, evaluator|
        if evaluator.with_gces
          create(:application_qualification, application_form: application_form, subject: 'maths', level: 'gcse', qualification_type: 'GCSE')
          create(:application_qualification, application_form: application_form, subject: 'english', level: 'gcse', qualification_type: 'GCSE')
          create(:application_qualification, application_form: application_form, subject: 'science', level: 'gcse', qualification_type: 'GCSE')
        end

        edit_by = if application_form.submitted_at.nil?
                    nil
                  else
                    5.business_days.after application_form.submitted_at
                  end

        create_list(:application_choice, evaluator.application_choices_count, application_form: application_form, status: 'awaiting_references', edit_by: edit_by)
        create_list(:application_work_experience, evaluator.work_experiences_count, application_form: application_form)
        create_list(:application_volunteering_experience, evaluator.volunteering_experiences_count, application_form: application_form)
        create_list(:reference, evaluator.references_count, evaluator.references_state, application_form: application_form)
        # The application_form validates the length of this collection when
        # it is created, which is BEFORE we create the references here.
        # This then *caches* the association on the  application_form, and means
        # you have to explicitly reload it to pick up the created references.
        # We do this here, so we only have to do it in one place, rather than
        # everywhere we refer to application_form.application_references in tests.
        # See https://github.com/thoughtbot/factory_bot/issues/549 for details.
        if evaluator.references_count > 0
          application_form.application_references.reload
        end
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

    code { Faker::Alphanumeric.unique.alphanumeric(number: 1).upcase }
    name { Faker::Educator.secondary_school }
    address_line1 { Faker::Address.street_address }
    address_line2 { Faker::Address.city }
    address_line3 { Faker::Address.county }
    address_line4 { '' }
    postcode { Faker::Address.postcode }
  end

  factory :course_option do
    course
    site { association(:site, provider: course.provider) }

    vacancy_status { 'B' }
  end

  factory :course do
    provider

    code { Faker::Alphanumeric.alphanumeric(number: 4, min_alpha: 1).upcase }
    name { Faker::Educator.subject }
    level { 'primary' }
    recruitment_cycle_year { 2020 }

    trait :open_on_apply do
      open_on_apply { true }
      exposed_in_find { true }
    end
  end

  factory :provider do
    initialize_with { Provider.find_or_create_by code: code }
    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    name { Faker::Educator.university }

    trait :with_signed_agreement do
      after(:build) do |provider|
        create(:provider_agreement, provider: provider)
      end
    end
  end

  factory :provider_agreement do
    provider_user
    provider

    agreement_type { :data_sharing_agreement }
    accept_agreement { true }

    after(:build) do |_agreement, evaluator|
      evaluator.provider.provider_users << evaluator.provider_user
    end
  end

  factory :application_choice do
    application_form
    course_option

    status { ApplicationStateChange.valid_states.sample }
    personal_statement { 'hello' }

    factory :submitted_application_choice do
      status { 'awaiting_provider_decision' }
      reject_by_default_at { Time.zone.now + 40.days }
      reject_by_default_days { 40 }
      association :application_form, factory: %i[completed_application_form with_completed_references]
    end

    trait :awaiting_provider_decision do
      association :application_form, factory: %i[completed_application_form with_completed_references]
      status { :awaiting_provider_decision }

      reject_by_default_days { 40 }
      reject_by_default_at { 40.business_days.from_now }
    end

    trait :ready_to_send_to_provider do
      status { :application_complete }
      edit_by { 1.day.ago }
    end

    trait :with_offer do
      status { 'offer' }
      decline_by_default_at { Time.zone.now + 10.days }
      decline_by_default_days { 10 }
      offer { { 'conditions' => ['Be cool'] } }
    end

    trait :with_accepted_offer do
      with_offer
      status { 'pending_conditions' }
      accepted_at { Time.zone.now - 2.days }
    end
  end

  factory :vendor_api_user do
    vendor_api_token

    full_name { 'Bob' }
    email_address { 'bob@example.com' }
    vendor_user_id { '123' }
  end

  factory :vendor_api_token do
    provider

    hashed_token { '1234567890' }
  end

  factory :reference, class: 'ApplicationReference' do
    email_address { "#{SecureRandom.hex(5)}@example.com" }
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    relationship { Faker::Lorem.paragraph(sentence_count: 3) }

    trait :unsubmitted do
      feedback { nil }
    end

    trait :complete do
      feedback_status { 'feedback_provided' }
      feedback { Faker::Lorem.paragraph(sentence_count: 10) }
    end
  end

  factory :support_user do
    dfe_sign_in_uid { SecureRandom.uuid }
    email_address { "#{Faker::Name.first_name.downcase}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end

  factory :provider_user do
    dfe_sign_in_uid { SecureRandom.uuid }
    email_address { "#{Faker::Name.first_name.downcase}-#{SecureRandom.hex}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
