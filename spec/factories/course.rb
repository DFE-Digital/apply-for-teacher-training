FactoryBot.define do
  factory :course do
    provider

    code { Faker::Alphanumeric.unique.alphanumeric(number: 4, min_alpha: 1).upcase }
    name { Faker::Educator.subject }
    level { 'primary' }
    recruitment_cycle_year { CycleTimetableHelper.current_year }
    description { 'PGCE with QTS full time' }
    qualifications { %w[qts pgce] }
    course_length { 'OneYear' }
    start_date { Faker::Date.between(from: 1.month.from_now, to: 1.year.from_now) }
    applications_open_from { CycleTimetableHelper.current_timetable.apply_opens_at }
    age_range { '4 to 8' }
    withdrawn { false }
    program_type { 'scitt_programme' }

    can_sponsor_skilled_worker_visa { false }
    can_sponsor_student_visa { false }

    funding_type { %w[fee salary apprenticeship].sample }
    course_subjects { [association(:course_subject, course: instance)] }

    trait :unavailable do
      exposed_in_find { false }
    end

    trait :open do
      application_status { 'open' }
      exposed_in_find { true }
      applications_open_from { 2.months.ago }
    end

    trait :closed do
      application_status { 'closed' }
    end

    trait :with_accredited_provider do
      accredited_provider { create(:provider) }
    end

    trait :primary do
      level { 'primary' }
    end

    trait :secondary do
      level { 'secondary' }
    end

    trait :with_provider_relationship_permissions do
      with_accredited_provider

      after(:build) do |_, evaluator|
        create(:provider_relationship_permissions,
               training_provider: evaluator.provider,
               ratifying_provider: evaluator.accredited_provider)
      end
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

    trait :uuid do
      uuid { SecureRandom.uuid }
    end

    trait :teacher_degree_apprenticeship do
      apprenticeship
      full_time
      description { 'Teacher degree apprenticeship with QTS' }

      qualifications { %w[qts undergraduate_degree] }
      program_type { 'TDA' }
      course_length { '4 years' }
    end

    trait :previous_year do
      recruitment_cycle_year { CycleTimetableHelper.previous_year }
    end

    trait :previous_year_but_still_available do
      previous_year
      available_the_year_after
    end

    trait :available_in_current_and_next_year do
      recruitment_cycle_year { CycleTimetableHelper.current_year }
      available_the_year_after
    end

    trait :available_the_year_after do
      after(:create) do |course|
        new_course = course.dup
        new_course.update(recruitment_cycle_year: course.recruitment_cycle_year + 1)
      end
    end

    trait :fee_paying do
      funding_type { 'fee' }
    end

    trait :salaried do
      funding_type { 'salary' }
    end

    trait :apprenticeship do
      funding_type { 'apprenticeship' }
    end

    trait :with_course_options do
      course_options { build_list(:course_option, 2, course: instance) }
    end

    trait :with_manchester_course_site do
      course_options { [create(:course_option, :manchester_site, course: instance)] }
    end

    trait :with_a_course_option do
      course_options { [create(:course_option, course: instance)] }
    end

    trait :with_no_vacancies do
      course_options { build_list(:course_option, 2, :no_vacancies, course: instance) }
    end
  end
end
