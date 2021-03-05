FactoryBot.define do
  factory :ucas_match do
    candidate { application_form.candidate }
    matching_data { nil }
    recruitment_cycle_year { application_form.recruitment_cycle_year }

    transient do
      application_form { create(:completed_application_form, submitted_application_choices_count: 1) }
      ucas_status { nil }
      scheme { rand(1..3).times.map { %w[U D B].sample } }
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

        candidate_id = ucas_match.candidate.id.to_s
        shared_data = {
          'Apply candidate ID' => candidate_id,
          'Trackable applicant key' => "ABC#{candidate_id}UCAS",
        }

        # Don't generate Apply's ApplicationChoice for an application on UCAS
        if evaluator.scheme&.include?('U')
          ucas_applications_data = evaluator.scheme.count('U').times.map do
            status_on_ucas = ucas_statuses[evaluator.ucas_status] || ucas_statuses[%i[rejected withdrawn declined offer awaiting_provider_decision].sample]
            provider = create(:provider)
            { 'Scheme' => 'U',
              'Course code' => Faker::Alphanumeric.alphanumeric(number: 4, min_alpha: 1).upcase,
              'Provider code' => provider.code }.merge!(shared_data).merge!(status_on_ucas)
          end
          evaluator.scheme.delete('U')
        end

        apply_applications_data = evaluator.application_form.application_choices.map do |application_choice|
          scheme = evaluator.scheme.pop || 'B'
          data = {
            'Scheme' => scheme,
            'Course code' => application_choice.offered_option.course.code.to_s,
            'Provider code' => application_choice.offered_option.course.provider.code.to_s,
          }.merge!(shared_data)

          if scheme == 'B'
            status_on_ucas = ucas_statuses[evaluator.ucas_status] || ucas_statuses[%i[rejected withdrawn declined offer awaiting_provider_decision].sample]
            data.merge!(status_on_ucas)
          end
          data
        end

        ucas_match.matching_data = [ucas_applications_data, apply_applications_data].flatten.compact
      end
    end

    trait :with_dual_application do
      scheme { %w[B] }
      application_form { create(:completed_application_form, application_choices: [create(:submitted_application_choice)]) }
      ucas_status { :awaiting_provider_decision }
    end

    trait :with_multiple_acceptances do
      scheme { %w[U D] }
      application_form do
        create(:completed_application_form, application_choices: [create(:application_choice, :with_accepted_offer)])
      end
      ucas_status { :pending_conditions }
    end

    trait :need_to_send_reminder_emails do
      action_taken  { 'initial_emails_sent' }
      candidate_last_contacted_at { 5.business_days.before(Time.zone.now) }
    end

    trait :need_to_request_withdrawal_from_ucas do
      action_taken { 'reminder_emails_sent' }
      candidate_last_contacted_at { 5.business_days.before(Time.zone.now) }
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

    trait :minimum_info do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      date_of_birth { Faker::Date.birthday }
      phone_number { Faker::PhoneNumber.cell_phone }
      first_nationality { 'British' }
      second_nationality { 'American' }
      address_line1 { Faker::Address.street_address }
      country { 'GB' }
      interview_preferences { Faker::Lorem.paragraph_by_chars(number: 100) }
      safeguarding_issues_status { 'no_safeguarding_issues_to_declare' }
      submitted_at { Faker::Time.backward(days: 7, period: :day) }
    end

    trait :international_address do
      address_type { :international }
      country { Faker::Address.country_code }
    end

    trait :with_completed_references do
      minimum_info

      support_reference { GenerateSupportReference.call }
      transient do
        references_state { :feedback_provided }
      end
    end

    trait :with_feedback_completed do
      feedback_satisfaction_level { ApplicationForm.feedback_satisfaction_levels.values.sample }
      feedback_suggestions { Faker::Lorem.paragraph_by_chars(number: 200) }
    end

    trait :with_equality_and_diversity_data do
      equality_and_diversity do
        ethnicity = Class.new.extend(EthnicBackgroundHelper).all_combinations.sample
        other_disability = 'Acquired brain injury'
        all_disabilities = CandidateInterface::EqualityAndDiversity::DisabilitiesForm::DISABILITIES.map(&:second) << other_disability
        disabilities = rand < 0.85 ? all_disabilities.sample([*0..3].sample) : ['Prefer not to say']
        hesa_sex = %w[1 2 3].sample
        hesa_disabilities = disabilities ? [HESA_DISABILITIES.map(&:first).sample] : %w[00]
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

    trait :with_safeguarding_issues_never_asked do
      safeguarding_issues_status { 'never_asked' }
    end

    trait :with_degree do
      application_qualifications { [association(:degree_qualification, application_form: instance)] }
    end

    trait :with_gcses do
      application_qualifications do
        %i[maths english science].map do |subject|
          association(:gcse_qualification, application_form: instance, subject: subject)
        end
      end
    end

    trait :with_degree_and_gcses do
      application_qualifications do
        [association(:gcse_qualification, application_form: instance, subject: 'maths'),
         association(:gcse_qualification, application_form: instance, subject: 'english'),
         association(:gcse_qualification, application_form: instance, subject: 'science'),
         association(:degree_qualification, application_form: instance)]
      end
    end

    trait :with_ucas_match do
      after(:create) do |application_form, _|
        create(:ucas_match, candidate: application_form.candidate)
      end
    end

    factory :completed_application_form do
      minimum_info

      support_reference { GenerateSupportReference.call }
      english_main_language { %w[true false].sample }
      english_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
      other_language_details { Faker::Lorem.paragraph_by_chars(number: 200) }
      further_information { Faker::Lorem.paragraph_by_chars(number: 300) }
      disclose_disability { %w[true false].sample }
      disability_disclosure { Faker::Lorem.paragraph_by_chars(number: 300) }
      address_line2 { Faker::Address.city }
      address_line3 { Faker::Address.county }
      address_line4 { '' }
      postcode { Faker::Address.postcode }
      becoming_a_teacher { Faker::Lorem.paragraph_by_chars(number: 500) }
      subject_knowledge { Faker::Lorem.paragraph_by_chars(number: 300) }
      work_history_explanation { Faker::Lorem.paragraph_by_chars(number: 400) }
      volunteering_experience { [true, false, nil].sample }
      phase { :apply_1 }
      recruitment_cycle_year { RecruitmentCycle.current_year }

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

      transient do
        application_choices_count { 0 }
        submitted_application_choices_count { 0 }
        work_experiences_count { 0 }
        volunteering_experiences_count { 0 }
        references_count { 0 }
        references_state { :feedback_requested }
        full_work_history { false }
      end

      after(:create) do |application_form, evaluator|
        application_form.application_choices << build_list(:application_choice, evaluator.application_choices_count, status: 'unsubmitted')
        application_form.application_choices << build_list(:submitted_application_choice, evaluator.submitted_application_choices_count, application_form: application_form)
        application_form.application_references << build_list(:reference, evaluator.references_count, evaluator.references_state)

        if evaluator.full_work_history
          current_year = Date.today.year
          first_start_date = Faker::Date.in_date_period(year: current_year - 5)
          first_end_date = Faker::Date.in_date_period(year: current_year - 4)
          first_job = build(:application_work_experience, start_date: first_start_date, end_date: first_end_date)

          second_start_date = Faker::Date.in_date_period(year: current_year - 3)
          second_end_date = Faker::Date.between(from: 1.year.ago, to: 6.months.ago)
          second_job = build(:application_work_experience, start_date: second_start_date, end_date: second_end_date)

          work_break = build(:application_work_history_break, start_date: second_start_date, end_date: second_end_date)

          application_form.application_work_experiences << [first_job, second_job]
          application_form.application_work_history_breaks << work_break
        else
          jobs = build_list(:application_work_experience, evaluator.work_experiences_count)
          application_form.application_work_experiences << jobs
        end

        volunteering_experience = build_list(:application_volunteering_experience, evaluator.volunteering_experiences_count)
        application_form.application_volunteering_experiences << volunteering_experience
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
    equivalency_details { Faker::Lorem.paragraph_by_chars(number: 200) }

    factory :gcse_qualification do
      level { 'gcse' }
      qualification_type { 'gcse' }
      subject { %w[maths english science].sample }
      grade { %w[A B C].sample }

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
    region { 'north_west' }
    postcode { Faker::Address.postcode }
  end

  factory :course_option do
    course
    site { association(:site, provider: course.provider) }

    vacancy_status { 'vacancies' }
    site_still_valid { true }

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

    trait :with_user do
      after(:create) do |provider|
        create(:provider_permissions, provider: provider)
      end
    end
  end

  factory :provider_agreement do
    provider_user
    provider

    agreement_type { :data_sharing_agreement }
    accept_agreement { true }

    after(:build) do |_agreement, evaluator|
      unless evaluator.provider.provider_users.exists?(evaluator.provider_user.id)
        evaluator.provider.provider_users << evaluator.provider_user
      end
    end
  end

  factory :provider_relationship_permissions do
    ratifying_provider { build(:provider) }
    training_provider { build(:provider) }
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
    course_option
    application_form

    status { ApplicationStateChange.valid_states.sample }

    trait :with_completed_application_form do
      association :application_form, factory: %i[completed_application_form]
    end

    trait :application_form_with_degree do
      association :application_form, factory: %i[completed_application_form with_degree]
    end

    factory :submitted_application_choice do
      status { 'awaiting_provider_decision' }
      reject_by_default_at { 40.business_days.from_now }
      reject_by_default_days { 40 }
    end

    trait :awaiting_provider_decision do
      status { :awaiting_provider_decision }

      reject_by_default_days { 40 }
      reject_by_default_at { 40.business_days.from_now }
    end

    trait :with_scheduled_interview do
      awaiting_provider_decision

      after(:build) do |application_choice, _evaluator|
        application_choice.status = :interviewing
        application_choice.interviews << build(:interview, provider: application_choice.provider)
      end
    end

    trait :with_cancelled_interview do
      awaiting_provider_decision

      after(:build) do |application_choice, _evaluator|
        application_choice.status = :awaiting_provider_decision
        application_choice.interviews << build(:interview, provider: application_choice.provider, cancelled_at: Time.zone.now)
      end
    end

    trait :withdrawn do
      status { :withdrawn }
      withdrawn_at { Time.zone.now }
    end

    trait :dbd do
      with_offer

      status { :declined }
      declined_by_default { true }
      decline_by_default_days { 10 }
    end

    trait :withdrawn_with_survey_completed do
      status { :withdrawn }
      withdrawn_at { Time.zone.now }
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
      rejected_at { 2.minutes.ago }
      rejected_by_default { true }
    end

    trait :with_rejection_by_default_and_feedback do
      with_rejection_by_default
      rejection_reason { Faker::Lorem.paragraph_by_chars(number: 200) }
      reject_by_default_feedback_sent_at { Time.zone.now }

      after(:create) do |_choice, evaluator|
        create(
          :application_choice_audit,
          :with_rejection_by_default_and_feedback,
          application_choice: evaluator,
        )
      end
    end

    trait :with_structured_rejection_reasons do
      with_rejection_by_default
      structured_rejection_reasons do
        {
          course_full_y_n: 'No',
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_other: 'Persistent scratching',
          candidate_behaviour_what_to_improve: 'Not scratch so much',
          candidate_behaviour_what_did_the_candidate_do: %w[didnt_reply_to_interview_offer didnt_attend_interview other],
          honesty_and_professionalism_y_n: 'Yes',
          honesty_and_professionalism_concerns_other_details: nil,
          honesty_and_professionalism_concerns: %w[information_false_or_inaccurate references],
          honesty_and_professionalism_concerns_plagiarism_details: nil,
          honesty_and_professionalism_concerns_references_details: 'Clearly not a popular student',
          honesty_and_professionalism_concerns_information_false_or_inaccurate_details: 'Fake news',
          offered_on_another_course_y_n: 'No',
          offered_on_another_course_details: nil,
          performance_at_interview_y_n: 'Yes',
          performance_at_interview_what_to_improve: 'Be fully dressed',
          qualifications_y_n: 'Yes',
          qualifications_other_details: 'All the other stuff',
          qualifications_which_qualifications: %w[no_english_gcse other],
          quality_of_application_y_n: 'Yes',
          quality_of_application_other_details: 'Lights on but nobody home',
          quality_of_application_other_what_to_improve: 'Study harder',
          quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge other],
          quality_of_application_subject_knowledge_what_to_improve: 'Claiming to be the \'world\'s leading expert\' seemed a bit strong',
          quality_of_application_personal_statement_what_to_improve: 'Use a spellchecker',
          safeguarding_y_n: 'Yes',
          safeguarding_concerns: %w[other],
          safeguarding_concerns_other_details: 'We need to run further checks',
          safeguarding_concerns_vetting_disclosed_information_details: nil,
          safeguarding_concerns_candidate_disclosed_information_details: nil,
          interested_in_future_applications_y_n: nil,
          why_are_you_rejecting_this_application: nil,
          other_advice_or_feedback_y_n: nil,
          other_advice_or_feedback_details: nil,
        }
      end
      reject_by_default_feedback_sent_at { Time.zone.now }

      after(:create) do |_choice, evaluator|
        create(
          :application_choice_audit,
          :with_rejection_by_default,
          application_choice: evaluator,
        )
      end
    end

    trait :application_not_sent do
      status { 'application_not_sent' }
      rejected_at { Time.zone.now }
      rejection_reason { 'Awaiting references when the recruitment cycle closed.' }
    end

    trait :with_offer do
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

    trait :with_changed_offer do
      with_offer

      after(:build) do |choice, _evaluator|
        other_course = create(:course, provider: choice.course_option.course.provider)
        choice.offered_course_option_id = create(:course_option, course: other_course).id
        choice.offer_changed_at = Time.zone.now - 1.day
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

    trait :with_conditions_not_met do
      with_accepted_offer
      status { 'conditions_not_met' }
      conditions_not_met_at { Time.zone.now }
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
      association :course_option, :previous_year

      after(:create) do |choice, _evaluator|
        choice.application_form.update_columns(
          recruitment_cycle_year: RecruitmentCycle.previous_year,
        )
      end
    end

    trait :previous_year_but_still_available do
      association :course_option, :previous_year_but_still_available

      after(:create) do |choice, _evaluator|
        choice.application_form.update_columns(
          recruitment_cycle_year: RecruitmentCycle.previous_year,
        )
      end
    end
  end

  factory :interview do
    application_choice

    date_and_time { 7.business_days.from_now }
    location { [Faker::Address.full_address, 'Link to video conference'].sample }
    additional_details { [nil, 'Use staff entrance', 'Ask for John at the reception'].sample }

    after(:build) do |interview|
      interview.application_choice.status = 'interviewing'
      interview.provider ||= interview.application_choice.offered_course.provider
    end

    trait :future_date_and_time do
      date_and_time { (1...10).to_a.sample.business_days.from_now + (0..8).to_a.sample.hours }
    end

    trait :past_date_and_time do
      date_and_time { (2...10).to_a.sample.business_days.ago - (0..8).to_a.sample.hours }
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

  factory :vendor_api_request do
    provider
    request_path { '/api/v1/applications' }
    request_method { 'GET' }
    status_code { 200 }
    request_headers { {} }
    request_body { {} }
    response_headers { {} }
    response_body { {} }
    created_at { Time.zone.now }
  end

  factory :reference, class: 'ApplicationReference' do
    application_form
    email_address { "#{SecureRandom.hex(5)}@example.com" }
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    relationship { Faker::Lorem.paragraph(sentence_count: 3) }
    referee_type { %i[academic professional school_based character].sample }
    questionnaire { nil }

    trait :not_requested_yet do
      feedback_status { 'not_requested_yet' }
      feedback { nil }
    end

    trait :feedback_refused do
      feedback_status { 'feedback_refused' }
      feedback { nil }
      requested_at { Time.zone.now - 1.day }
      feedback_refused_at { Time.zone.now }
    end

    trait :email_bounced do
      feedback_status { 'email_bounced' }
      feedback { nil }
      requested_at { Time.zone.now - 1.minute }
      email_bounced_at { Time.zone.now }
    end

    trait :cancelled do
      feedback_status { 'cancelled' }
      feedback { nil }
      requested_at { Time.zone.now - 1.day }
      cancelled_at { Time.zone.now }
    end

    trait :cancelled_at_end_of_cycle do
      feedback_status { 'cancelled_at_end_of_cycle' }
      feedback { nil }
      requested_at { Time.zone.now - 1.day }
      cancelled_at_end_of_cycle_at { Time.zone.now }
    end

    trait :feedback_requested do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { Time.zone.now }
    end

    trait :feedback_requested_less_than_5_days_ago do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { Time.zone.now - 2.days }
    end

    trait :feedback_requested_more_than_5_days_ago do
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

    trait :feedback_provided do
      feedback_status { 'feedback_provided' }
      feedback { Faker::Lorem.paragraph(sentence_count: 10) }
      requested_at { Time.zone.now - 1.day }
      feedback_provided_at { Time.zone.now }
      safeguarding_concerns { '' }
      relationship_correction { '' }
    end

    trait :feedback_provided_with_completed_referee_questionnaire do
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

  factory :dfe_sign_in_user do
    dfe_sign_in_uid { SecureRandom.uuid }
    email_address { "#{Faker::Name.first_name.downcase}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    initialize_with do
      new(
        dfe_sign_in_uid: dfe_sign_in_uid,
        email_address: email_address,
        first_name: first_name,
        last_name: last_name,
      )
    end
  end

  factory :support_user do
    dfe_sign_in_uid { SecureRandom.uuid }
    email_address { "#{Faker::Name.first_name.downcase}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end

  factory :authentication_token do
    user { create(:support_user) }
    hashed_token { SecureRandom.uuid }
  end

  factory :provider_user do
    dfe_sign_in_uid { SecureRandom.uuid }
    email_address { "#{Faker::Name.first_name.downcase}-#{SecureRandom.hex}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    send_notifications { Faker::Boolean.boolean(true_ratio: 0.5) }

    trait :with_provider do
      after(:create) do |user, _evaluator|
        create(:provider).provider_users << user
      end
    end

    trait :with_dfe_sign_in do
      dfe_sign_in_uid { 'DFE_SIGN_IN_UID' }

      after(:create) do |user, _evaluator|
        create(:provider, :with_signed_agreement).provider_users << user
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

    trait :with_view_diversity_information do
      after(:create) do |user, _evaluator|
        user.provider_permissions.update_all(view_diversity_information: true)
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

  factory :application_choice_audit, class: 'Audited::Audit' do
    action { 'update' }
    user { create(:support_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      application_choice { create(:application_choice, :awaiting_provider_decision) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ApplicationChoice'
      audit.auditable_id = evaluator.application_choice.id
      audit.associated = evaluator.application_choice.application_form
      audit.audited_changes = evaluator.changes
    end

    trait :awaiting_provider_decision do
      changes do
        {
          'status' => %w[unsubmitted awaiting_provider_decision],
        }
      end
    end

    trait :withdrawn do
      changes do
        {
          'status' => %w[awaiting_provider_decision withdrawn],
        }
      end
    end

    trait :with_rejection do
      association(:application_choice, :with_rejection)

      changes do
        {
          'status' => %w[awaiting_provider_decision rejected],
        }
      end
    end

    trait :with_rejection_by_default do
      application_choice { create(:application_choice, :with_rejection_by_default) }

      changes do
        {
          'status' => %w[awaiting_provider_decision rejected],
        }
      end

      after(:build) do |audit, _evaluator|
        audit.auditable.rejected_by_default = true
      end
    end

    trait :with_rejection_by_default_and_feedback do
      association(:application_choice, :with_rejection_by_default)

      changes do
        {
          'reject_by_default_feedback_sent_at' => [nil, Time.zone.now.iso8601],
        }
      end

      after(:build) do |audit, _evaluator|
        audit.auditable.rejected_by_default = true
      end
    end

    trait :with_declined_offer do
      association(:application_choice, :with_declined_offer)

      changes do
        {
          'status' => %w[offer declined],
        }
      end
    end

    trait :with_declined_by_default_offer do
      association(:application_choice, :with_declined_by_default_offer)

      changes do
        {
          'status' => %w[offer declined],
        }
      end

      after(:build) do |audit, _evaluator|
        audit.auditable.declined_by_default = true
      end
    end

    trait :with_offer do
      association(:application_choice, :with_offer)

      changes do
        {
          'status' => %w[awaiting_provider_decision offer],
          'offered_course_option_id' => [nil, application_choice.course_option_id],
        }
      end
    end

    trait :with_withdrawn_offer do
      association(:application_choice, :with_withdrawn_offer)

      changes do
        {
          'status' => %w[offer offer_withdrawn],
        }
      end
    end

    trait :with_modified_offer do
      association(:application_choice, :with_modified_offer)

      changes do
        {
          'status' => %w[awaiting_provider_decision offer],
          'offered_course_option_id' => [nil, application_choice.offered_course_option_id],
        }
      end
    end

    trait :with_changed_offer do
      association(:application_choice, :with_changed_offer)

      changes do
        {
          'offer_changed_at' => [nil, Time.zone.now.iso8601],
          'offered_course_option_id' => [nil, application_choice.offered_course_option_id],
        }
      end
    end

    trait :with_accepted_offer do
      association(:application_choice, :with_accepted_offer)

      changes do
        {
          'status' => %w[offer pending_conditions],
        }
      end
    end

    trait :with_conditions_not_met do
      association(:application_choice, :with_conditions_not_met)

      changes do
        {
          'status' => %w[pending_conditions conditions_not_met],
        }
      end
    end

    trait :with_recruited do
      association(:application_choice, :with_recruited)

      changes do
        {
          'status' => %w[pending_conditions recruited],
        }
      end
    end

    trait :with_deferred_offer do
      association(:application_choice, :with_deferred_offer)

      changes do
        {
          'status' => %w[pending_conditions offer_deferred],
        }
      end
    end

    trait :with_scheduled_interview do
      association(:application_choice, :with_scheduled_interview)

      changes do
        {
          'status' => %w[awaiting_provider_decision interviewing],
        }
      end
    end

    trait :with_cancelled_interview do
      association(:application_choice, :with_cancelled_interview)

      changes do
        {
          'status' => %w[awaiting_provider_decision],
        }
      end
    end
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
      after(:build) do |english_proficiency|
        english_proficiency.efl_qualification ||= create(:ielts_qualification, english_proficiency: english_proficiency)
        english_proficiency.qualification_status = 'has_qualification'
      end
    end

    trait :with_toefl_qualification do
      after(:build) do |english_proficiency|
        english_proficiency.efl_qualification ||= create(:toefl_qualification, english_proficiency: english_proficiency)
        english_proficiency.qualification_status = 'has_qualification'
      end
    end

    trait :with_other_efl_qualification do
      after(:build) do |english_proficiency|
        english_proficiency.efl_qualification ||= create(:other_efl_qualification, english_proficiency: english_proficiency)
        english_proficiency.qualification_status = 'has_qualification'
      end
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

  factory :application_feedback do
    application_form

    path { '/candidate/application/degrees' }
    page_title { Faker::Lorem.paragraph(sentence_count: 1) }
    feedback { Faker::Lorem.paragraph(sentence_count: 3) }
    consent_to_be_contacted { true }
  end

  factory :interview_audit, class: 'Audited::Audit' do
    action { 'create' }
    user { create(:provider_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      application_choice { build_stubbed(:application_choice, :awaiting_provider_decision) }
      interview { build_stubbed(:interview) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'Interview'
      audit.auditable_id = evaluator.interview.id
      audit.associated = evaluator.application_choice
      audit.audited_changes = evaluator.changes
    end
  end

  factory :email do
    application_form

    to { 'me@example.com' }
    subject { 'Test email' }
    mailer { 'ActionMailer' }
    mail_template { 'some_mail_template' }
    body { 'Hi' }
  end

  factory :provider_permissions_audit, class: 'Audited::Audit' do
    action { 'update' }
    user { create(:provider_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      provider_permissions { build_stubbed(:provider_permissions) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ProviderPermissions'
      audit.auditable_id = evaluator.provider_permissions.id
      audit.audited_changes = evaluator.changes
    end
  end

  factory :provider_relationship_permissions_audit, class: 'Audited::Audit' do
    action { 'update' }
    user { create(:provider_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      provider_relationship_permissions { build_stubbed(:provider_relationship_permissions) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ProviderRelationshipPermissions'
      audit.auditable_id = evaluator.provider_relationship_permissions.id
      audit.audited_changes = evaluator.changes
    end
  end
end
