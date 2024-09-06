FactoryBot.define do
  factory :course_option do
    course { association(:course, recruitment_cycle_year:) }
    site { association(:site, provider: course.provider) }

    vacancy_status { 'vacancies' }
    site_still_valid { true }

    transient do
      recruitment_cycle_year { RecruitmentCycle.current_year }
    end

    trait :open do
      course { association :course, :open, recruitment_cycle_year: }
    end

    trait :tda do
      course { association :course, :open, :teacher_degree_apprenticeship, recruitment_cycle_year: }
    end

    trait :with_course_uuid do
      course { association :course, :uuid, recruitment_cycle_year: }
    end

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
      course { association :course, :previous_year }
    end

    trait :previous_year_but_still_available do
      previous_year
      available_the_year_after
    end

    trait :available_in_current_and_next_year do
      course { create(:course, recruitment_cycle_year: RecruitmentCycle.current_year) }
      available_the_year_after
    end

    trait :available_the_year_after do
      after(:create) do |course_option|
        new_course = course_option.course.in_next_cycle
        new_site = create(
          :site,
          provider: course_option.course.provider,
          code: course_option.site.code,
          address_line1: course_option.site.address_line1,
          address_line2: course_option.site.address_line2,
          address_line3: course_option.site.address_line3,
          address_line4: course_option.site.address_line4,
          region: course_option.site.region,
          postcode: course_option.site.postcode,
        )

        unless new_course
          new_course = course_option.course.dup
          new_course.update!(
            code: course_option.course.code,
            recruitment_cycle_year: course_option.course.recruitment_cycle_year + 1,
          )
        end

        create(:course_option, course: new_course, site: new_site)
      end
    end
  end
end
