FactoryBot.define do
  factory :application_form do
    candidate
    address_type { 'uk' }

    after(:create) do |application_form, evaluator|
      if application_form.application_choices.empty? && evaluator.application_choices.any?
        application_form.application_choices << evaluator.application_choices
      end
    end

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

      references_completed { true }
    end

    trait :with_feedback_completed do
      feedback_satisfaction_level { ApplicationForm.feedback_satisfaction_levels.values.sample }
      feedback_suggestions { Faker::Lorem.paragraph_by_chars(number: 200) }
    end

    trait :with_equality_and_diversity_data do
      equality_and_diversity do
        sex = ['male', 'female', 'intersex', 'Prefer not to say'].sample
        ethnicity = Class.new.extend(EthnicBackgroundHelper).all_combinations.sample
        other_disability = 'Acquired brain injury'
        all_disabilities = DisabilityHelper::STANDARD_DISABILITIES.map(&:second) << other_disability
        disabilities = rand < 0.85 ? all_disabilities.sample([*0..3].sample) : ['Prefer not to say']
        hesa_sex = sex == 'Prefer not to say' ? nil : Hesa::Sex.find(sex)['hesa_code']
        hesa_disabilities = disabilities == ['Prefer not to say'] ? %w[00] : disabilities.map { |disability| Hesa::Disability.find(disability)['hesa_code'] }
        hesa_ethnicity = Hesa::Ethnicity.find(ethnicity.last, 2021)['hesa_code']

        {
          sex: sex,
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
      after(:create) do |application_form, _|
        create(:degree_qualification, application_form: application_form)
      end
    end

    trait :with_gcses do
      after(:create) do |application_form, _|
        %i[maths english science].each do |subject|
          create(:gcse_qualification, application_form: application_form, subject: subject)
        end
      end
    end

    trait :with_a_levels do
      after(:create) do |application_form, _|
        %i[Physics Chemistry Biology].sample([1, 2, 3].sample).each do |subject|
          create(
            :other_qualification,
            qualification_type: 'A level',
            application_form: application_form,
            subject: subject,
            grade: %w[A B C D E].sample,
          )
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
      address_line3 { Faker::Address.city }
      address_line4 { Faker::Address.county }
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
          current_year = Time.zone.today.year
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
end
