FactoryBot.define do
  factory :ucas_match do
    candidate { application_form.candidate }
    matching_state { %w[new_match matching_data_updated processed].sample }
    matching_data { nil }

    transient do
      application_form { create(:completed_application_form, application_choices_count: 1) }
      ucas_status { nil }
      scheme { nil }
    end

    after(:build) do |ucas_match, evaluator|
      if ucas_match.matching_data.nil?
        ucas_statuses = {
          rejected: { 'Rejects' => '1' },
          withdrawn: { 'Withdrawns' => '1' },
          declined: { 'Declined offers' => '1' },
          offer: { 'Offers' => '1' },
          pending_conditions: { 'Offers' => '1', 'Conditional firm' => '1' },
          recruited: { 'Offers' => '1', 'Unconditional firm' => '1' },
          awaiting_provider_decision: { 'Applications' => '1' },
        }.freeze

        ucas_match.matching_data = evaluator.application_form.application_choices.map do |application_choice|
          scheme = evaluator.scheme || %w[U D B].sample

          data = {
            'Scheme' => scheme,
            'Apply candidate ID' => ucas_match.candidate.id.to_s,
            'Course code' => application_choice.offered_option.course.code.to_s,
            'Provider code' => application_choice.offered_option.course.provider.code.to_s,
          }

          unless scheme == 'D'
            status_on_ucas = ucas_statuses[evaluator.ucas_status] || ucas_statuses[%i[rejected withdrawn declined offer awaiting_provider_decision].sample]
            data.merge!(status_on_ucas)
          end

          data
        end
      end
    end
  end

  factory :chaser_sent do
    association :chased, factory: :candidate
    chaser_type { :reference_request }
  end

  factory :candidate do
    email_address { "#{SecureRandom.hex(5)}@example.com" }
    sign_up_email_bounced { false }
  end

  factory :application_form do
    candidate
    address_type { 'uk' }

    factory :completed_application_form do
      support_reference { GenerateSupportRef.call }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      date_of_birth { Faker::Date.birthday }
      first_nationality { 'British' }
      english_main_language { %w[true false].sample }
      english_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
      other_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
      further_information { Faker::Lorem.paragraph_by_chars(number: 300) }
      disclose_disability { %w[true false].sample }
      disability_disclosure { Faker::Lorem.paragraph_by_chars(number: 300) }
      safeguarding_issues_status { 'no_safeguarding_issues_to_declare' }
      submitted_at { Faker::Time.backward(days: 7, period: :day) }
      edit_by { submitted_at ? 5.business_days.after(submitted_at) : nil }
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
      phase { :apply_1 }

      # Checkboxes to mark a section as complete
      course_choices_completed { true }
      degrees_completed { true }
      other_qualifications_completed { true }
      volunteering_completed { true }
      work_history_completed { true }
      personal_details_completed { true }
      contact_details_completed { true }
      english_gcse_completed { true }
      maths_gcse_completed { true }
      science_gcse_completed { true }
      training_with_a_disability_completed { true }
      safeguarding_issues_completed { true }
      becoming_a_teacher_completed { true }
      subject_knowledge_completed { true }
      interview_preferences_completed { true }
      references_completed { true }

      transient do
        application_choices_count { 0 }
        work_experiences_count { 0 }
        volunteering_experiences_count { 0 }
        references_count { 0 }
        references_state { :requested }
        with_gcses { false }
        full_work_history { false }
        with_degree { false }
        with_ucas_match { false }
      end

      trait :international_address do
        address_type { :international }
        international_address { Faker::Address.city }
        country { Faker::Address.country_code }
        address_line1 { nil }
        address_line2 { nil }
        address_line3 { nil }
      end

      trait :ready_to_send_to_provider do
        edit_by { 1.day.ago }
      end

      trait :with_completed_references do
        transient do
          references_state { :complete }
        end
      end

      trait :with_survey_completed do
        satisfaction_survey do
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
        end
      end

      trait :with_equality_and_diversity_data do
        equality_and_diversity do
          ethnicity = Class.new.extend(EthnicBackgroundHelper).all_combinations.sample
          other_disability = 'Acquired brain injury'
          all_disabilities = CandidateInterface::EqualityAndDiversity::DisabilitiesForm::DISABILITIES.map(&:second) << other_disability
          disabilities = rand < 0.85 ? all_disabilities.sample([*0..3].sample) : ['Prefer not to say']
          hesa_sex = [1, 2, 3].sample
          hesa_disabilities = disabilities ? HESA_DISABILITIES.map(&:first).sample : %w[00]
          hesa_ethnicity = HESA_ETHNICITIES_2020_2021.map(&:first).sample

          {
            sex: ['male', 'female', 'intersex', 'Prefer not to say'].sample,
            ethnic_group: ethnicity.first,
            ethnic_background: ethnicity.last,
            disabilities: disabilities,
            hesa_sex: hesa_sex,
            hesa_disabilities: hesa_disabilities,
            hesa_ethnicity: hesa_ethnicity,
          }
        end
      end

      trait :with_safeguarding_issues_disclosed do
        safeguarding_issues_status { 'has_safeguarding_issues_to_declare' }
        safeguarding_issues { 'I have a criminal conviction.' }
      end

      trait :with_no_safeguarding_issues_to_declare do
        safeguarding_issues_status { 'no_safeguarding_issues_to_declare' }
      end

      trait :with_safeguarding_issues_never_asked do
        safeguarding_issues_status { 'never_asked' }
      end

      after(:build) do |application_form, evaluator|
        if evaluator.with_gcses
          create(:gcse_qualification, application_form: application_form, subject: 'maths')
          create(:gcse_qualification, application_form: application_form, subject: 'english')
          create(:gcse_qualification, application_form: application_form, subject: 'science')
        end

        if evaluator.with_degree
          create(:degree_qualification, application_form: application_form)
        end

        create_list(:application_choice, evaluator.application_choices_count, application_form: application_form, status: 'awaiting_references')
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

        if evaluator.with_ucas_match
          create(:ucas_match, candidate: application_form.candidate)
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
    application_form
    level { %w[degree gcse other].sample }
    qualification_type { %w[BA Masters A-Level gcse].sample }
    subject { Faker::Educator.subject }
    grade { %w[A B].sample }
    predicted_grade { %w[true false].sample }
    start_year { Date.today.year }
    award_year { Faker::Date.between(from: 60.years.ago, to: 3.years.from_now).year }
    institution_name { Faker::University.name }
    institution_country { Faker::Address.country_code }
    awarding_body { Faker::University.name }
    equivalency_details { Faker::Lorem.paragraph_by_chars(number: 200) }

    factory :gcse_qualification do
      level { 'gcse' }
      qualification_type { 'gcse' }
      subject { %w[maths english science].sample }
      grade { %w[A B C].sample }
      awarding_body { Faker::Educator.secondary_school }

      trait :non_uk do
        qualification_type { 'non_uk' }
        non_uk_qualification_type { 'High School Diploma' }
        grade { %w[pass merit distinction].sample }
        institution_country { Faker::Address.country_code }
        naric_reference { '4000123456' }
        comparable_uk_qualification { 'Between GCSE and GCSE AS Level' }
      end

      trait :missing do
        qualification_type { 'missing' }
        grade { nil }
        awarding_body { nil }
        missing_explanation { 'I will be taking an equivalency test in a few weeks' }
      end
    end

    factory :degree_qualification do
      level { 'degree' }
      qualification_type { Hesa::DegreeType.all.sample.name }
      subject { Hesa::Subject.all.sample.name }
      institution_name { Hesa::Institution.all.sample.name }
      grade { Hesa::Grade.all.sample.description }

      after(:build) do |degree, _evaluator|
        degree.qualification_type_hesa_code = Hesa::DegreeType.find_by_name(degree.qualification_type)&.hesa_code
        degree.subject_hesa_code = Hesa::Subject.find_by_name(degree.subject)&.hesa_code
        degree.institution_hesa_code = Hesa::Institution.find_by_name(degree.institution_name)&.hesa_code
        degree.grade_hesa_code = Hesa::Grade.find_by_description(degree.grade)&.hesa_code
      end
    end

    factory :other_qualification do
      level { 'other' }
      qualification_type { 'Other' }
      other_uk_qualification_type { Faker::Educator.subject }
      subject { Faker::Educator.subject }
      institution_name { Faker::University.name }
      grade { %w[pass merit distinction].sample }
      institution_country { 'GB' }

      trait :non_uk do
        level { 'other' }
        qualification_type { 'non_uk' }
        non_uk_qualification_type { Faker::Educator.subject }
        subject { Faker::Educator.subject }
        institution_name { Faker::University.name }
        grade { %w[pass merit distinction].sample }
        institution_country { Faker::Address.country_code }
      end
    end
  end

  factory :site do
    provider

    code { Faker::Alphanumeric.unique.alphanumeric(number: 5).upcase }
    name { "#{Faker::Educator.secondary_school} #{rand(100..999)}" }
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

    trait :previous_year do
      course { create(:course, :previous_year) }
    end

    trait :previous_year_but_still_available do
      previous_year

      after(:create) do |course_option|
        unless (new_course = course_option.course.in_next_cycle)
          new_course = course_option.course.dup
          new_course.recruitment_cycle_year = RecruitmentCycle.current_year
          new_course.open_on_apply = true
          new_course.save
        end

        create(:course_option, course: new_course, site: course_option.site)
      end
    end
  end

  factory :course do
    provider

    code { Faker::Alphanumeric.alphanumeric(number: 4, min_alpha: 1).upcase }
    name { Faker::Educator.subject }
    level { 'primary' }
    recruitment_cycle_year { RecruitmentCycle.current_year }
    description { 'PGCE with QTS full time' }
    course_length { 'OneYear' }
    start_date { Faker::Date.between(from: 1.month.from_now, to: 1.year.from_now) }
    age_range { '4 to 8' }
    withdrawn { false }

    subject_codes { [Faker::Alphanumeric.alphanumeric(number: 2, min_alpha: 1).upcase] }
    funding_type { %w[fee salary apprenticeship].sample }

    trait :open_on_apply do
      open_on_apply { true }
      exposed_in_find { true }
    end

    trait :with_accredited_provider do
      accredited_provider { create(:provider) }
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

    trait :previous_year do
      recruitment_cycle_year { RecruitmentCycle.previous_year }
    end

    trait :previous_year_but_still_available do
      previous_year

      after(:create) do |course|
        new_course = course.dup
        new_course.recruitment_cycle_year = RecruitmentCycle.current_year
        new_course.save
      end
    end
  end

  factory :provider do
    initialize_with { Provider.find_or_initialize_by(code: code) }
    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    name { Faker::University.name }

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

  factory :provider_relationship_permissions do
    ratifying_provider { create(:provider) }
    training_provider { create(:provider) }
    training_provider_can_make_decisions { true }
    training_provider_can_view_safeguarding_information { true }
    training_provider_can_view_diversity_information { true }
    setup_at { Time.zone.now }

    trait :not_set_up_yet do
      training_provider_can_make_decisions { false }
      training_provider_can_view_safeguarding_information { false }
      training_provider_can_view_diversity_information { false }
      setup_at { nil }
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

    factory :awaiting_references_application_choice do
      status { 'awaiting_references' }
      reject_by_default_at { 40.business_days.from_now }
      reject_by_default_days { 40 }
      association :application_form, factory: %i[completed_application_form]
    end

    trait :awaiting_provider_decision do
      association :application_form, factory: %i[completed_application_form with_completed_references]
      status { :awaiting_provider_decision }

      reject_by_default_days { 40 }
      reject_by_default_at { 40.business_days.from_now }
    end

    trait :ready_to_send_to_provider do
      association :application_form, factory: %i[completed_application_form with_completed_references ready_to_send_to_provider]
      status { :application_complete }
    end

    trait :withdrawn do
      status { :withdrawn }
    end

    trait :withdrawn_with_survey_completed do
      association :application_form, factory: %i[completed_application_form with_completed_references ready_to_send_to_provider]
      status { :withdrawn }
      withdrawal_feedback do
        {
          CandidateInterface::WithdrawalQuestionnaire::EXPLANATION_QUESTION => 'yes',
          'Explanation' => Faker::Lorem.paragraph_by_chars(number: 300),
          CandidateInterface::WithdrawalQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => 'yes',
          'Contact details' => Faker::PhoneNumber.cell_phone,
        }
      end
    end

    trait :with_rejection do
      status { 'rejected' }
      rejection_reason { Faker::Lorem.paragraph_by_chars(number: 300) }
      rejected_at { Time.zone.now }
    end

    trait :with_rejection_by_default do
      status { 'rejected' }
      rejected_at { Time.zone.now }
      rejected_by_default { true }
    end

    trait :application_not_sent do
      status { 'application_not_sent' }
      rejected_at { Time.zone.now }
      rejection_reason { 'Awaiting references when the recruitment cycle closed.' }
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

    trait :with_withdrawn_offer do
      with_offer
      status { 'offer_withdrawn' }
      offer_withdrawal_reason { 'There has been a mistake' }
      offer_withdrawn_at { Time.zone.now - 1.day }
    end

    trait :with_recruited do
      with_accepted_offer
      status { 'recruited' }
      recruited_at { Time.zone.now }
    end

    trait :with_deferred_offer do
      with_accepted_offer
      status { 'offer_deferred' }
      status_before_deferral { 'pending_conditions' }
      offer_deferred_at { Time.zone.now - 1.day }
    end

    trait :with_deferred_offer_previously_recruited do
      with_deferred_offer
      status_before_deferral { 'recruited' }
      recruited_at { Time.zone.now - 1.day }
    end

    trait :previous_year do
      course_option { create(:course_option, :previous_year) }
    end

    trait :previous_year_but_still_available do
      course_option { create(:course_option, :previous_year_but_still_available) }
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
      hashed_token do
        _unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token)
        hashed_token
      end
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

    trait :cancelled_at_end_of_cycle do
      feedback_status { 'cancelled_at_end_of_cycle' }
      feedback { nil }
      requested_at { Time.zone.now }
    end

    trait :requested do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { Time.zone.now }
    end

    trait :sent_less_than_5_days_ago do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { Time.zone.now - 2.days }
    end

    trait :sent_more_than_5_days_ago do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { Time.zone.now - 6.days }
    end

    trait :feedback_overdue do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { 11.business_days.ago }
      created_at { 11.business_days.ago }
    end

    trait :complete do
      feedback_status { 'feedback_provided' }
      feedback { Faker::Lorem.paragraph(sentence_count: 10) }
      requested_at { Time.zone.now }
      questionnaire do
        {
          RefereeQuestionnaire::GUIDANCE_QUESTION => "#{%w[very_poor poor ok good very_good].sample} | #{Faker::Lorem.paragraph_by_chars(number: 300)}",
          RefereeQuestionnaire::EXPERIENCE_QUESTION => "#{%w[very_poor poor ok good very_good].sample} | #{Faker::Lorem.paragraph_by_chars(number: 300)}",
          RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => "#{%w[yes no].sample} | #{Faker::PhoneNumber.cell_phone}",
          'If we asked whether a candidate was safe to work with children, would you feel able to answer?' => "#{%w[yes no].sample}| ",
        }
      end
      safeguarding_concerns { '' }
      relationship_correction { '' }
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

  factory :authentication_token do
    authenticable { support_user }
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

    trait :with_manage_organisations do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(manage_organisations: true)
      end
    end

    trait :with_manage_users do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(manage_users: true)
      end
    end

    trait :with_make_decisions do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(make_decisions: true)
      end
    end

    trait :with_view_safeguarding_information do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(view_safeguarding_information: true)
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

  factory :note do
    application_choice
    provider_user

    subject { Faker::Company.bs.capitalize }
    message { Faker::Quote.most_interesting_man_in_the_world }
  end

  factory :feature do
    name { 'feature_x' }
  end

  factory :english_proficiency do
    application_form
    qualification_status { 'no_qualification' }

    trait :no_qualification do
      qualification_status { 'no_qualification' }
    end

    trait :with_ielts_qualification do
      association :efl_qualification, factory: :ielts_qualification
      qualification_status { 'has_qualification' }
    end

    trait :with_toefl_qualification do
      association :efl_qualification, factory: :toefl_qualification
      qualification_status { 'has_qualification' }
    end

    trait :with_other_qualification do
      association :efl_qualification, factory: :other_efl_qualification
      qualification_status { 'has_qualification' }
    end

    trait :qualification_not_needed do
      qualification_status { 'qualification_not_needed' }
    end
  end

  factory :ielts_qualification do
    trf_number { '123456' }
    band_score { '6.5' }
    award_year { 1999 }
  end

  factory :toefl_qualification do
    registration_number { '123456' }
    total_score { 20 }
    award_year { 1999 }
  end

  factory :other_efl_qualification do
    name { 'Cockney Rhyming Slang Proficiency Test' }
    grade { 10 }
    award_year { 2001 }
  end
end
