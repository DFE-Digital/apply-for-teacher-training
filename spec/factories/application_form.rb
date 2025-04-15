require 'dfe/reference_data/countries_and_territories'

FactoryBot.define do
  factory :application_form do
    candidate
    address_type { :uk }

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

      submitted_at { (created_at || Time.zone.now) + 1.second }
    end

    trait :submitted do
      minimum_info
    end

    trait :duplicate_candidates do
      date_of_birth { ApplicationForm.last&.date_of_birth || '01-01-1996' }
      postcode { ApplicationForm.last&.postcode || 'W6 9BH' }
      last_name { 'Thompson' }
    end

    trait :international_address do
      address_type { :international }
      country { Faker::Address.country_code }
    end

    trait :with_safeguarding_issues_never_asked do
      safeguarding_issues_status { 'never_asked' }
    end

    trait :with_domestic_adviser_qualifications do
      application_qualifications do
        [
          association(:gcse_qualification, application_form: instance, subject: 'maths'),
          association(:gcse_qualification, application_form: instance, subject: 'english'),
          association(:gcse_qualification, application_form: instance, subject: 'science'),
          association(:degree_qualification, :adviser_sign_up_applicable, application_form: instance),
        ]
      end
    end

    trait :with_international_adviser_qualifications do
      application_qualifications do
        [
          association(:gcse_qualification, application_form: instance, subject: 'maths'),
          association(:gcse_qualification, application_form: instance, subject: 'english'),
          association(:gcse_qualification, application_form: instance, subject: 'science'),
          association(:non_uk_degree_qualification, :adviser_sign_up_applicable, predicted_grade: true, application_form: instance),
        ]
      end
    end

    trait :with_bachelor_degree do
      university_degree { true }
      after(:create) do |application_form, _|
        create(:degree_qualification, :bachelor, application_form:)
      end
    end

    trait :with_degree do
      university_degree { true }
      after(:create) do |application_form, _|
        create(:degree_qualification, application_form:)
      end
    end

    trait :with_gcses do
      after(:create) do |application_form, _|
        create(:gcse_qualification, application_form:, subject: 'maths')
        create(:gcse_qualification, :multiple_english_gcses, application_form:)
        create(:gcse_qualification, :science_gcse, application_form:)
      end
    end

    trait :with_a_levels do
      after(:create) do |application_form, _|
        %i[Physics Chemistry Biology].sample([1, 2, 3].sample).each do |subject|
          create(
            :other_qualification,
            qualification_type: 'A level',
            application_form:,
            subject:,
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

    trait :with_completed_references do
      completed

      transient do
        references_state { :feedback_provided }
        references_count { 2 }
      end

      references_completed { true }
    end

    trait :unsubmitted do
      submitted_at { nil }
    end

    trait :with_feedback_completed do
      feedback_satisfaction_level { ApplicationForm.feedback_satisfaction_levels.values.sample }
      feedback_suggestions { Faker::Lorem.paragraph_by_chars(number: 200) }
    end

    transient do
      sex { ['male', 'female', 'other', 'Prefer not to say'].sample }
    end

    trait :with_other_disability do
      equality_and_diversity do
        all_ethnicities = Class.new.extend(EthnicBackgroundHelper).all_combinations

        sex = 'female'
        hesa_sex = '10'

        disabilities = ['I am allergic to cats']
        hesa_disabilities = %w[96]

        ethnicity = all_ethnicities.sample
        hesa_ethnicity = Hesa::Ethnicity.find(ethnicity.last, CycleTimetableHelper.current_year)['hesa_code']

        {
          sex:,
          ethnic_group: ethnicity.first,
          ethnic_background: ethnicity.last,
          disabilities:,
          hesa_sex:,
          hesa_disabilities:,
          hesa_ethnicity:,
        }
      end
    end

    trait :with_prefer_not_to_say_disability do
      equality_and_diversity do
        all_ethnicities = Class.new.extend(EthnicBackgroundHelper).all_combinations

        sex = 'female'
        hesa_sex = '10'

        disabilities = ['Prefer not to say']
        hesa_disabilities = %w[98]

        ethnicity = all_ethnicities.sample
        hesa_ethnicity = Hesa::Ethnicity.find(ethnicity.last, CycleTimetableHelper.current_year)['hesa_code']

        {
          sex:,
          ethnic_group: ethnicity.first,
          ethnic_background: ethnicity.last,
          disabilities:,
          hesa_sex:,
          hesa_disabilities:,
          hesa_ethnicity:,
        }
      end
    end

    trait :with_no_disabilities do
      equality_and_diversity do
        all_ethnicities = Class.new.extend(EthnicBackgroundHelper).all_combinations

        sex = 'female'
        hesa_sex = '10'

        disabilities = []
        hesa_disabilities = []

        ethnicity = all_ethnicities.sample
        hesa_ethnicity = Hesa::Ethnicity.find(ethnicity.last, CycleTimetableHelper.current_year)['hesa_code']

        {
          sex:,
          ethnic_group: ethnicity.first,
          ethnic_background: ethnicity.last,
          disabilities:,
          hesa_sex:,
          hesa_disabilities:,
          hesa_ethnicity:,
        }
      end
    end

    trait :with_equality_and_diversity_data do
      transient do
        with_disability_randomness { true }
      end

      equality_and_diversity do
        all_ethnicities = Class.new.extend(EthnicBackgroundHelper).all_combinations
        if CycleTimetableHelper.current_year < HesaChanges::YEAR_2023
          all_ethnicities -= [%w[White Irish], %w[White Roma]]
        end
        ethnicity = all_ethnicities.sample
        other_disability = 'Acquired brain injury'
        all_disabilities = DisabilityHelper::STANDARD_DISABILITIES.map(&:second) << other_disability
        if CycleTimetableHelper.current_year < HesaChanges::YEAR_2023
          # Not included in other years
          all_disabilities.delete(I18n.t('equality_and_diversity.disabilities.development_condition')[:label])
        end

        disabilities = if with_disability_randomness
                         rand < 0.85 ? all_disabilities.sample([*0..3].sample) : ['Prefer not to say']
                       else
                         all_disabilities.first(2)
                       end

        hesa_sex = if sex == 'Prefer not to say'
                     '96'
                   elsif (hesa = Hesa::Sex.find(sex, CycleTimetableHelper.current_year)).present?
                     hesa['hesa_code']
                   else
                     raise "Could not find a `Hesa::Sex` entry for sex `#{sex}` in cycle `#{CycleTimetableHelper.current_year}`"
                   end

        hesa_disabilities = disabilities == ['Prefer not to say'] ? %w[00] : disabilities.map { |disability| Hesa::Disability.find(disability)['hesa_code'] }
        hesa_ethnicity = Hesa::Ethnicity.find(ethnicity.last, CycleTimetableHelper.current_year)['hesa_code']

        {
          sex:,
          ethnic_group: ethnicity.first,
          ethnic_background: ethnicity.last,
          disabilities:,
          hesa_sex:,
          hesa_disabilities:,
          hesa_ethnicity:,
        }
      end
    end

    trait :eligible_for_free_school_meals do
      first_nationality { %w[British Irish].sample }
      date_of_birth { 20.years.ago }
    end

    trait :with_safeguarding_issues_disclosed do
      safeguarding_issues_status { 'has_safeguarding_issues_to_declare' }
      safeguarding_issues { 'I have a criminal conviction.' }
    end

    trait :with_accepted_offer do
      completed

      transient do
        submitted_application_choices_count { 1 }
        with_accepted_offer { true }
      end
    end

    trait :completed do
      submitted
      with_equality_and_diversity_data

      support_reference { GenerateSupportReference.call }

      further_information { Faker::Lorem.paragraph_by_chars(number: 300) }
      disclose_disability { %w[true false].sample }
      disability_disclosure do
        Faker::Lorem.paragraph_by_chars(number: 300) if disclose_disability
      end
      address_line3 { Faker::Address.city }
      address_line4 { Faker::Address.uk_country }
      postcode {
        new_prefix = DfE::ReferenceData::CountriesAndTerritories::UK_AND_CI_POSTCODE_PREFIX_COUNTRIES.one(address_line4).prefixes.sample
        Faker::Address.postcode.sub(/^[a-zA-Z]+/, new_prefix)
      }
      becoming_a_teacher { Faker::Lorem.sentence(word_count: 500) }
      work_history_explanation { Faker::Lorem.paragraph_by_chars(number: 400) }
      volunteering_experience { [true, false, nil].sample }
      phase { :apply_1 }
      recruitment_cycle_year { CycleTimetableHelper.current_year }

      right_to_work_or_study {
        if first_nationality != 'British'
          %w[yes no].sample
        end
      }
      immigration_status {
        if right_to_work_or_study == 'yes'
          %w[eu_settled eu_pre_settled other].sample
        end
      }
      right_to_work_or_study_details {
        if immigration_status == 'other'
          'Indefinite leave to remain'
        end
      }

      # Checkboxes to mark a section as complete
      becoming_a_teacher_completed { true }
      contact_details_completed { true }
      course_choices_completed { true }
      degrees_completed { true }
      english_gcse_completed { true }
      interview_preferences_completed { true }
      maths_gcse_completed { true }
      other_qualifications_completed { true }
      personal_details_completed { true }
      references_completed { true }
      safeguarding_issues_completed { true }
      science_gcse_completed { true }
      training_with_a_disability_completed { true }
      volunteering_completed { true }
      work_history_completed { true }
      equality_and_diversity_completed { true }
      # The form isn't completed if the nationality is not British/Irish
      # without the efl_completed
      #
      # efl_completed { true }

      transient do
        application_choices_count { 0 }
        submitted_application_choices_count { 0 }
        with_accepted_offer { false }

        full_work_history { false }
        volunteering_experiences_count { 0 }
        work_experiences_count { 0 }

        references_count { 2 }
        references_state { :feedback_provided }
      end

      after(:create) do |application_form, evaluator|
        original_updated_at = application_form.updated_at

        application_form.class.with_unsafe_application_choice_touches do
          application_form.application_choices << build_list(:application_choice, evaluator.application_choices_count, status: 'unsubmitted')
          application_form.application_choices << build_list(:application_choice, evaluator.submitted_application_choices_count, evaluator.with_accepted_offer ? :accepted : :awaiting_provider_decision, application_form:)
          application_form.application_references << build_list(:reference, evaluator.references_count, evaluator.references_state)
        end

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

        application_form.update!(updated_at: original_updated_at)
      end
    end

    trait :pre_continuous_applications do
      recruitment_cycle_year { 2023 }
    end

    trait :carry_over do
      completed
      recruitment_cycle_year { CycleTimetableHelper.current_year }
      created_at { CycleTimetableHelper.mid_cycle }
      updated_at { CycleTimetableHelper.mid_cycle }

      previous_application_form do
        previous_year = CycleTimetableHelper.previous_year
        association(
          :completed_application_form,
          recruitment_cycle_year: previous_year,
          submitted_at: CycleTimetableHelper.mid_cycle(previous_year),
          first_name:,
          last_name:,
          candidate:,
          created_at: CycleTimetableHelper.mid_cycle(previous_year),
          updated_at: CycleTimetableHelper.mid_cycle(previous_year),
          submitted_application_choices_count: 1,
        )
      end
    end

    trait :apply_again do
      completed
      created_at { CycleTimetableHelper.before_apply_deadline }
      updated_at { CycleTimetableHelper.before_apply_deadline }
      recruitment_cycle_year { CycleTimetableHelper.current_year }
      phase { 'apply_2' }

      previous_application_form do
        association(
          :completed_application_form,
          recruitment_cycle_year:,
          submitted_at: submitted_at - 10.days,
          first_name:,
          last_name:,
          candidate:,
          created_at: CycleTimetableHelper.mid_cycle,
          updated_at: CycleTimetableHelper.mid_cycle,
        )
      end
    end

    factory :completed_application_form do
      completed
    end

    factory :application_form_eligible_for_adviser do
      completed
      with_domestic_adviser_qualifications
      submitted_at { nil }
    end
  end
end
