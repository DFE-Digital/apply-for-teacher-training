FactoryBot.define do
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
        new_course = course_option.course.in_next_cycle
        unless new_course
          new_course = course_option.course.dup
          new_course.recruitment_cycle_year = RecruitmentCycle.current_year
          new_course.open_on_apply = true
          new_course.save
        end

        create(:course_option, course: new_course, site: course_option.site)
      end
    end
  end
end
