FactoryBot.define do
  factory :chaser_sent do
    candidate
    chased_id { candidate.id }
    chased_type { candidate.class }
    chaser_type { :reference_request }
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
      safeguarding_issues { 'I have a criminal conviction.' }

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
        references_state { :requested }
        with_gces { false }
        full_work_history { false }
      end

      trait :with_completed_references do
        transient do
          references_state { :complete }
        end
      end

      trait :with_survey_completed do
        satisfaction_survey {
          {
             I18n.t('page_titles.recommendation') => [*1..5].sample.to_s,
             I18n.t('page_titles.complexity') => [*1..5].sample.to_s,
             I18n.t('page_titles.ease_of_use') => [*1..5].sample.to_s,
             I18n.t('page_titles.help_needed') => [*1..5].sample.to_s,
             I18n.t('page_titles.organisation') => [*1..5].sample.to_s,
             I18n.t('page_titles.consistency') => [*1..5].sample.to_s,
             I18n.t('page_titles.adaptability') => [*1..5].sample.to_s,
             I18n.t('page_titles.awkward') => [*1..5].sample.to_s,
             I18n.t('page_titles.confidence') => [*1..5].sample.to_s,
             I18n.t('page_titles.needed_additional_learning') => [*1..5].sample.to_s,
             I18n.t('page_titles.improvements') => Faker::Lorem.paragraph_by_chars(number: 400),
             I18n.t('page_titles.other_information') => Faker::Lorem.paragraph_by_chars(number: 400),
             I18n.t('page_titles.contact') => %w[yes no].sample,
           }
        }
      end

      trait :with_equality_and_diversity_data do
        equality_and_diversity {
          ethnicity = Class.new.extend(EthnicBackgroundHelper).all_combinations.sample
          all_disabilities = CandidateInterface::EqualityAndDiversity::DisabilitiesForm::DISABILITIES.map(&:first) << 'Other'
          disabilities = all_disabilities.sample([*1..3].sample)
          {
            sex: ['male', 'female', 'intersex', 'Prefer not to say'].sample,
            ethnic_group: ethnicity.first,
            ethnic_background: ethnicity.last,
            disability_status: 'yes',
            disabilities: disabilities,
            other_disability: (disabilities.include?('Other') ? Faker::Lorem.paragraph(sentence_count: 2) : nil),
          }
        }
      end

      after(:build) do |application_form, evaluator|
        if evaluator.with_gces
          create(:gcse_qualification, application_form: application_form, subject: 'maths')
          create(:gcse_qualification, application_form: application_form, subject: 'english')
          create(:gcse_qualification, application_form: application_form, subject: 'science')
        end

        edit_by = if application_form.submitted_at.nil?
                    nil
                  else
                    5.business_days.after application_form.submitted_at
                  end

        create_list(:application_choice, evaluator.application_choices_count, application_form: application_form, status: 'awaiting_references', edit_by: edit_by)
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

        if evaluator.full_work_history
          first_start_date = rand(63..70).months.ago
          first_end_date = rand(50..58).months.ago
          second_start_date = rand(36..47).months.ago
          second_end_date = rand(6..12).months.ago
          create(
            :application_work_experience,
            application_form: application_form,
            start_date: first_start_date,
            end_date: first_end_date,
          )
          create(
            :application_work_history_break,
            application_form: application_form,
            start_date: first_end_date,
            end_date: second_start_date,
          )
          create(
            :application_work_experience,
            application_form: application_form,
            start_date: second_start_date,
            end_date: second_end_date,
          )
        else
          create_list(:application_work_experience, evaluator.work_experiences_count, application_form: application_form)
        end
        create_list(:application_volunteering_experience, evaluator.volunteering_experiences_count, application_form: application_form)
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
    working_pattern { Faker::Lorem.paragraph_by_chars(number: 30) }
  end

  factory :application_work_history_break do
    start_date { Faker::Date.between(from: 20.years.ago, to: 5.years.ago) }
    end_date { Faker::Date.between(from: 4.years.ago, to: Date.today) }
    reason { Faker::Lorem.sentence(word_count: 400) }
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

    factory :gcse_qualification do
      level { 'gcse' }
      qualification_type { 'GCSE' }
      subject { %w[maths english science].sample }
      grade { %w[A B C].sample }
      awarding_body { Faker::Educator.secondary_school }
    end

    factory :degree_qualification do
      level { 'degree' }
      qualification_type { %w[BA Masters].sample }
      grade { %w[first upper_second lower_second third].sample }
    end

    factory :other_qualification do
      level { 'other' }
      qualification_type { %w[Diploma Doctorate NVQ Foundation].sample }
      grade { %w[pass merit distinction].sample }
    end
  end

  factory :site do
    provider

    code { Faker::Alphanumeric.unique.alphanumeric(number: 1).upcase }
    name { Faker::Educator.unique.secondary_school }
    address_line1 { Faker::Address.street_address }
    address_line2 { Faker::Address.city }
    address_line3 { Faker::Address.county }
    address_line4 { '' }
    postcode { Faker::Address.postcode }
  end

  factory :course_option do
    course
    site { association(:site, provider: course.provider) }

    vacancy_status { 'vacancies' }

    trait :full_time do
      study_mode { :full_time }
    end

    trait :part_time do
      study_mode { :part_time }
    end

    trait :no_vacancies do
      vacancy_status { 'no_vacancies' }
    end
  end

  factory :course do
    provider

    code { Faker::Alphanumeric.alphanumeric(number: 4, min_alpha: 1).upcase }
    name { Faker::Educator.subject }
    level { 'primary' }
    recruitment_cycle_year { 2020 }
    description { 'PGCE with QTS full time' }
    course_length { 'OneYear' }
    start_date { Faker::Date.between(from: 1.month.from_now, to: 1.year.from_now) }
    age_range { '4 to 8' }

    subject_codes { [Faker::Alphanumeric.alphanumeric(number: 2, min_alpha: 1).upcase] }

    trait :open_on_apply do
      open_on_apply { true }
      exposed_in_find { true }
    end

    trait :with_both_study_modes do
      study_mode { :full_time_or_part_time }
    end

    trait :full_time do
      study_mode { :full_time }
    end

    trait :part_time do
      study_mode { :part_time }
    end
  end

  factory :provider do
    initialize_with { Provider.find_or_initialize_by(code: code) }
    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    name { Faker::Educator.university }

    trait :with_signed_agreement do
      after(:create) do |provider|
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

    factory :submitted_application_choice do
      status { 'awaiting_provider_decision' }
      reject_by_default_at { 40.business_days.from_now }
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
      association :application_form, factory: %i[completed_application_form with_completed_references]
      status { :application_complete }
      edit_by { 1.day.ago }
    end

    trait :with_rejection do
      status { 'rejected' }
      rejection_reason { 'candidate did not meet minimum course entry requirements' }
      rejected_at { Time.zone.now }
    end

    trait :with_rejection_by_default do
      status { 'rejected' }
      rejected_at { Time.zone.now }
      rejected_by_default { true }
    end

    trait :with_offer do
      association :application_form, factory: %i[completed_application_form with_completed_references]
      status { 'offer' }
      decline_by_default_at { Time.zone.now + 7.days }
      decline_by_default_days { 10 }
      offer { { 'conditions' => ['Be cool'] } }
      offered_at { Time.zone.now - 3.days }
    end

    trait :with_modified_offer do
      with_offer

      after(:build) do |choice, _evaluator|
        other_course = create(:course, provider: choice.course_option.course.provider)
        choice.offered_course_option_id = create(:course_option, course: other_course).id
      end
    end

    trait :with_accepted_offer do
      with_offer
      status { 'pending_conditions' }
      accepted_at { Time.zone.now - 2.days }
    end

    trait :with_declined_offer do
      with_offer
      status { 'declined' }
      declined_at { Time.zone.now - 2.days }
    end

    trait :with_declined_by_default_offer do
      with_offer
      status { 'declined' }
      declined_at { Time.zone.now }
      declined_by_default { true }
    end
  end

  factory :vendor_api_user, class: 'VendorApiUser' do
    vendor_api_token

    full_name { 'Bob' }
    email_address { 'bob@example.com' }
    vendor_user_id { '123' }
  end

  factory :vendor_api_token do
    provider

    hashed_token { '1234567890' }

    trait :with_random_token do
      hashed_token { _unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token); hashed_token }
    end
  end

  factory :reference, class: 'ApplicationReference' do
    application_form
    email_address { "#{SecureRandom.hex(5)}@example.com" }
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    relationship { Faker::Lorem.paragraph(sentence_count: 3) }
    referee_type { %i[academic professional school_based character].sample }
    questionnaire { nil }

    trait :unsubmitted do
      feedback_status { 'not_requested_yet' }
      feedback { nil }
    end

    trait :refused do
      feedback_status { 'feedback_refused' }
      feedback { nil }
      requested_at { Time.zone.now }
    end

    trait :email_bounced do
      feedback_status { 'email_bounced' }
      feedback { nil }
      requested_at { Time.zone.now }
    end

    trait :cancelled do
      feedback_status { 'cancelled' }
      feedback { nil }
      requested_at { Time.zone.now }
    end

    trait :requested do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { Time.zone.now }
    end

    trait :complete do
      feedback_status { 'feedback_provided' }
      feedback { Faker::Lorem.paragraph(sentence_count: 10) }
      requested_at { Time.zone.now }
      questionnaire {
        {
          'Please rate how useful our guidance was' => "#{%w[very_poor poor ok good very_good].sample} | #{Faker::Lorem.paragraph_by_chars(number: 300)}",
          'Please rate your experience of giving a reference' =>  "#{%w[very_poor poor ok good very_good].sample} | #{Faker::Lorem.paragraph_by_chars(number: 300)}",
          'Can we contact you about your experience of giving a reference?' => "#{%w[yes no].sample} | #{Faker::PhoneNumber.cell_phone}",
          'If we asked whether a candidate was safe to work with children, would you feel able to answer?' => "#{%w[yes no].sample}| ",
        }
      }
    end
  end

  factory :reference_token do
    association :application_reference, factory: :reference

    hashed_token { '1234567890' }
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

    trait :with_provider do
      after(:create) do |user, _evaluator|
        create(:provider).provider_users << user
      end
    end

    trait :with_two_providers do
      after(:create) do |user, _evaluator|
        2.times { create(:provider).provider_users << user }
      end
    end
  end

  factory :provider_permissions do
    provider
    provider_user
  end

  factory :validation_error do
    form_object { 'RefereeInterface::ReferenceFeedbackForm' }
    details { { feedback: { messages: ['Enter feedback'], value: '' } } }
    association :user, factory: :candidate
    request_path { '/candidate' }
  end
end
